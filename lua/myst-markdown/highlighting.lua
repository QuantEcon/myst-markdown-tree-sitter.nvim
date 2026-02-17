--- Highlighting module for MyST Markdown
--- Manages tree-sitter parser registration and highlight group creation.
local M = {}
local utils = require("myst-markdown.utils")

--- Augroup name used for all highlighting autocmds
local AUGROUP = "MystMarkdownHighlighting"

--- Register the myst filetype to use the markdown parser.
--- Uses the modern vim.treesitter.language.register() API when available,
--- falling back to the legacy nvim-treesitter filetype_to_parsername table.
---@return boolean Whether registration succeeded
local function register_parser_mapping()
  -- Modern API (Neovim >= 0.9)
  if vim.treesitter.language and vim.treesitter.language.register then
    local ok, err = pcall(vim.treesitter.language.register, "markdown", "myst")
    if ok then
      utils.debug("Registered myst -> markdown parser (modern API)")
      return true
    end
    utils.debug("vim.treesitter.language.register failed: " .. tostring(err))
  end

  -- Legacy fallback via nvim-treesitter
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok and parsers then
    if not parsers.filetype_to_parsername then
      parsers.filetype_to_parsername = {}
    end
    parsers.filetype_to_parsername.myst = "markdown"
    utils.debug("Registered myst -> markdown parser (legacy API)")
    return true
  end

  utils.warn("Could not register myst -> markdown parser mapping")
  return false
end

--- Setup highlight groups for MyST elements
function M.setup_highlight_groups()
  vim.api.nvim_set_hl(0, "@myst.code_cell.directive", { link = "Special" })
  vim.api.nvim_set_hl(0, "@myst.directive", { link = "Special" })
  utils.debug("MyST highlight groups configured")
end

--- Setup tree-sitter highlighting for a single buffer
---@param buf number Buffer handle (0 = current buffer)
---@return boolean Whether setup succeeded
function M.setup_treesitter(buf)
  buf = buf or 0

  if not utils.is_valid_buffer(buf) then
    utils.warn("Invalid buffer for tree-sitter setup")
    return false
  end

  -- Ensure parser mapping is registered
  register_parser_mapping()

  -- Start tree-sitter highlighting with the markdown parser
  if vim.treesitter.start then
    local start_ok = pcall(vim.treesitter.start, buf, "markdown")
    if not start_ok then
      utils.warn("Failed to start tree-sitter highlighting")
      return false
    end
  else
    -- Fallback for Neovim < 0.9
    local real_buf = utils.resolve_buf(buf)
    vim.bo[real_buf].syntax = "markdown" -- luacheck: ignore 122
    utils.debug("Using fallback syntax highlighting (Neovim < 0.9)")
  end

  return true
end

--- Setup FileType autocmd that initialises highlighting for every myst buffer.
--- Uses an augroup so repeated calls to setup() are idempotent.
function M.setup_filetype_autocmd()
  local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "myst",
    callback = function(args)
      M.setup_treesitter(args.buf)
      M.setup_highlight_groups()
    end,
    desc = "Setup MyST tree-sitter highlighting on FileType event",
  })

  -- Also register the parser mapping eagerly so queries resolve before any
  -- FileType event fires (e.g. when ftdetect sets the filetype).
  register_parser_mapping()
  M.setup_highlight_groups()
end

return M
