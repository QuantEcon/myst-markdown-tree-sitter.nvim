--- Highlighting module for MyST Markdown
local M = {}
local utils = require("myst-markdown.utils")
local config = require("myst-markdown.config")

--- Setup highlight groups for MyST elements
function M.setup_highlight_groups()
  -- Create highlight groups for MyST directives
  -- Note: Priority parameter removed for compatibility with older Neovim versions
  vim.api.nvim_set_hl(0, "@myst.code_cell.directive", {
    link = "Special",
  })
  
  -- Additional MyST-specific highlights
  vim.api.nvim_set_hl(0, "@myst.directive", {
    link = "Special",
  })
  
  utils.debug("MyST highlight groups configured")
end

--- Setup tree-sitter highlighting for MyST filetype
---@param buf number|nil Buffer handle (defaults to current buffer)
function M.setup_treesitter(buf)
  buf = buf or 0
  
  if not utils.is_valid_buffer(buf) then
    utils.warn("Invalid buffer for tree-sitter setup")
    return false
  end
  
  if not utils.has_treesitter() then
    utils.warn("nvim-treesitter not available")
    return false
  end
  
  -- Configure parser for myst filetype to use markdown parser
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    utils.error("Failed to load nvim-treesitter.parsers")
    return false
  end
  
  -- Set up filetype to parser mapping
  if not parsers.filetype_to_parsername then
    parsers.filetype_to_parsername = {}
  end
  parsers.filetype_to_parsername.myst = "markdown"
  
  -- Start tree-sitter highlighting with markdown parser
  if vim.treesitter.start then
    local start_ok = pcall(vim.treesitter.start, buf, "markdown")
    if not start_ok then
      utils.warn("Failed to start tree-sitter highlighting")
      return false
    end
  else
    -- Fallback for older Neovim versions
    vim.bo[buf].syntax = "markdown"
    utils.debug("Using fallback syntax highlighting")
  end
  
  return true
end

--- Setup MyST highlighting for current buffer
---@param buf number|nil Buffer handle (defaults to current buffer)
function M.setup(buf)
  buf = buf or 0
  
  -- Setup highlight groups
  M.setup_highlight_groups()
  
  -- Setup tree-sitter
  local success = M.setup_treesitter(buf)
  
  if success then
    utils.debug("MyST highlighting enabled for buffer " .. buf)
  else
    utils.warn("MyST highlighting setup incomplete for buffer " .. buf)
  end
  
  return success
end

--- Setup FileType autocmd for myst filetype
function M.setup_filetype_autocmd()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "myst",
    callback = function(args)
      local buf = args.buf
      
      -- Setup tree-sitter highlighting
      M.setup_treesitter(buf)
      
      -- Setup MyST highlighting
      M.setup_highlight_groups()
    end,
    desc = "Setup MyST highlighting on FileType event",
  })
end

return M
