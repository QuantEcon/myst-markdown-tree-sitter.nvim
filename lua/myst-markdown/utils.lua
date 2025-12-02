--- Utility functions for myst-markdown plugin
local M = {}

--- Log levels for consistent messaging
M.log_levels = {
  ERROR = vim.log.levels.ERROR,
  WARN = vim.log.levels.WARN,
  INFO = vim.log.levels.INFO,
  DEBUG = vim.log.levels.DEBUG,
}

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

--- Log a debug message
---@param msg string Debug message
function M.debug(msg)
  M.log(msg, M.log_levels.DEBUG)
end

--- Check if a buffer is valid and loaded
---@param buf number Buffer handle
---@return boolean Whether buffer is valid
function M.is_valid_buffer(buf)
  return buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)
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
  if not M.has_treesitter() then
    return false
  end

  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return false
  end

  return parsers.has_parser(lang)
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
