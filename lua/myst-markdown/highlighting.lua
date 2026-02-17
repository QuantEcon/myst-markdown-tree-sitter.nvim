--- Highlighting module for MyST Markdown
--- Manages tree-sitter parser registration and highlight group creation.
local M = {}
local utils = require("myst-markdown.utils")

--- Augroup name used for all highlighting autocmds
local AUGROUP = "MystMarkdownHighlighting"

--- Whether we have already invalidated the query cache during this session.
local _cache_invalidated = false

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

--- Invalidate cached tree-sitter queries for the markdown parser so that
--- our injection queries (from queries/markdown/) are picked up even when
--- the plugin loads after nvim-treesitter has already cached queries.
--- This handles the common case where a plugin manager (e.g. lazy.nvim with
--- ft-based loading) adds this plugin to the runtimepath after the markdown
--- parser has already started with its own queries.
---@return boolean Whether invalidation succeeded
function M.invalidate_query_cache()
  if _cache_invalidated then
    return true
  end

  local ok = false

  -- Neovim >= 0.10: public API
  if vim.treesitter.query.invalidate then
    pcall(vim.treesitter.query.invalidate, "markdown")
    pcall(vim.treesitter.query.invalidate, "markdown_inline")
    utils.debug("Invalidated markdown query cache (public API)")
    ok = true
  else
    -- Neovim 0.9: internal cache table
    local query_mod = vim.treesitter.query
    if type(query_mod) == "table" then
      for _, cache_key in ipairs({ "_query_cache", "cache" }) do
        local cache = rawget(query_mod, cache_key)
        if type(cache) == "table" then
          cache["markdown"] = nil
          cache["markdown_inline"] = nil
          utils.debug("Invalidated markdown query cache (internal: " .. cache_key .. ")")
          ok = true
          break
        end
      end
    end
  end

  if ok then
    _cache_invalidated = true
  else
    utils.debug("Could not invalidate query cache (no known cache found)")
  end

  return ok
end

--- Restart tree-sitter highlighting on already-open myst/markdown buffers.
--- Called after query cache invalidation to pick up the new injection queries.
function M.refresh_active_buffers()
  if not vim.treesitter.start then
    return
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      if ft == "myst" or ft == "markdown" then
        -- Stop then restart so the LanguageTree re-reads queries
        pcall(vim.treesitter.stop, buf)
        pcall(vim.treesitter.start, buf, "markdown")
        utils.debug("Refreshed tree-sitter highlighting for buffer " .. buf)
      end
    end
  end
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

  -- If there are already-open markdown/myst buffers, the plugin loaded after
  -- files were opened (e.g. lazy.nvim ft-based loading).  Invalidate the
  -- query cache and restart highlighting so our injection queries are used.
  -- Deferred via vim.schedule to avoid interfering with ongoing initialisation.
  local has_open_buffers = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      if ft == "myst" or ft == "markdown" then
        has_open_buffers = true
        break
      end
    end
  end

  if has_open_buffers then
    vim.schedule(function()
      M.invalidate_query_cache()
      M.refresh_active_buffers()
    end)
  end
end

return M
