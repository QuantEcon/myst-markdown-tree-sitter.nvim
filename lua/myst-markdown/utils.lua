--- Utility functions for myst-markdown plugin
local M = {}

--- Log levels for consistent messaging
M.log_levels = {
  ERROR = vim.log.levels.ERROR,
  WARN = vim.log.levels.WARN,
  INFO = vim.log.levels.INFO,
  DEBUG = vim.log.levels.DEBUG,
}

--- Internal flag set by init.lua when debug mode is enabled.
--- Avoids repeated pcall(require) on every debug() call.
M._debug_enabled = false

--- Log a message with the plugin prefix
---@param msg string Message to log
---@param level number|nil Log level (default: INFO)
function M.log(msg, level)
  level = level or M.log_levels.INFO
  vim.notify("[myst-markdown] " .. msg, level)
end

--- Log an error message
---@param msg string Error message
function M.error(msg)
  M.log(msg, M.log_levels.ERROR)
end

--- Log a warning message
---@param msg string Warning message
function M.warn(msg)
  M.log(msg, M.log_levels.WARN)
end

--- Log an info message
---@param msg string Info message
function M.info(msg)
  M.log(msg, M.log_levels.INFO)
end

--- Log a debug message (only shown when debug = true in config)
---@param msg string Debug message
function M.debug(msg)
  if M._debug_enabled then
    M.log(msg, M.log_levels.DEBUG)
  end
end

--- Resolve a buffer handle.
--- Converts 0 (current buffer alias) to the real buffer number.
---@param buf number Buffer handle (may be 0)
---@return number Resolved buffer number
function M.resolve_buf(buf)
  if buf == 0 then
    return vim.api.nvim_get_current_buf()
  end
  return buf
end

--- Check if a buffer is valid and loaded
---@param buf number Buffer handle (0 is accepted as current buffer)
---@return boolean Whether buffer is valid
function M.is_valid_buffer(buf)
  if buf == nil then
    return false
  end
  buf = M.resolve_buf(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)
end

--- Safely get buffer lines
---@param buf number Buffer handle
---@param start number Start line (0-indexed)
---@param end_line number End line (0-indexed, -1 for end of buffer)
---@return table|nil Lines or nil on error
function M.get_buf_lines(buf, start, end_line)
  if not M.is_valid_buffer(buf) then
    return nil
  end
  buf = M.resolve_buf(buf)

  local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, start, end_line, false)
  if not ok then
    M.warn("Failed to get buffer lines: " .. tostring(lines))
    return nil
  end

  return lines
end

--- Check if tree-sitter is available
---@return boolean Whether nvim-treesitter is available
function M.has_treesitter()
  return pcall(require, "nvim-treesitter.configs")
end

--- Check if a specific tree-sitter parser is available
---@param lang string Parser language
---@return boolean Whether parser is available
function M.has_parser(lang)
  -- Try the modern vim.treesitter API first (Neovim >= 0.9)
  if vim.treesitter.language and vim.treesitter.language.get_lang then
    local ok = pcall(vim.treesitter.language.add, lang)
    return ok
  end

  -- Fall back to nvim-treesitter
  if not M.has_treesitter() then
    return false
  end
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return false
  end
  return parsers.has_parser(lang)
end

--- Get a tree-sitter query safely across Neovim versions
--- Handles the rename from vim.treesitter.query.get_query (old) to
--- vim.treesitter.query.get (new, >= 0.9)
---@param lang string Parser language
---@param query_name string Query name (e.g. "injections", "highlights")
---@return any|nil Query object or nil
function M.ts_get_query(lang, query_name)
  local get_fn = vim.treesitter.query.get or vim.treesitter.query.get_query
  if not get_fn then
    return nil
  end
  local ok, query = pcall(get_fn, lang, query_name)
  if ok then
    return query
  end
  return nil
end

--- Check if Neovim version meets minimum requirement
---@param major number Major version
---@param minor number Minor version
---@param patch number|nil Patch version
---@return boolean Whether version requirement is met
function M.check_version(major, minor, patch)
  patch = patch or 0
  return vim.fn.has(string.format("nvim-%d.%d.%d", major, minor, patch)) == 1
end

--- Check if string matches any pattern in a list
---@param str string String to check
---@param patterns table List of Lua patterns
---@return boolean, string|nil Matches, matched pattern
function M.matches_any(str, patterns)
  for _, pattern in ipairs(patterns) do
    if str:match(pattern) then
      return true, pattern
    end
  end
  return false, nil
end

return M
