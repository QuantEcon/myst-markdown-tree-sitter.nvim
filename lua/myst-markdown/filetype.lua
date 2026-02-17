--- Filetype detection module for MyST Markdown
--- Note: Primary filetype detection is in ftdetect/myst.lua which runs before plugins.
--- This module provides:
--- 1. A reusable detect_myst() function with caching
--- 2. Secondary detection to override markdown filetype if another plugin sets it
--- 3. Cache invalidation on buffer changes
local M = {}
local utils = require("myst-markdown.utils")
local config = require("myst-markdown.config")

--- Augroup name used for all filetype autocmds
local AUGROUP = "MystMarkdownFiletype"

--- Cache for filetype detection results
--- Key: buffer number, Value: boolean (is_myst)
local detection_cache = {}

--- Detect if buffer contains MyST patterns
---@param buf number Buffer handle
---@return boolean Whether buffer contains MyST content
function M.detect_myst(buf)
  buf = utils.resolve_buf(buf)

  -- Check cache first
  if config.get_value("performance.cache_enabled") then
    local cached = detection_cache[buf]
    if cached ~= nil then
      return cached
    end
  end

  -- Get buffer lines to scan
  local scan_lines = config.get_value("detection.scan_lines") or 50
  local lines = utils.get_buf_lines(buf, 0, scan_lines)

  if not lines then
    return false
  end

  -- Get detection patterns from config
  local patterns = config.get_value("detection.patterns") or {}
  local all_patterns = {
    patterns.code_cell,
    patterns.myst_directive,
    patterns.standalone_directive,
  }

  -- Check each line for MyST patterns
  for _, line in ipairs(lines) do
    if utils.matches_any(line, all_patterns) then
      if config.get_value("performance.cache_enabled") then
        detection_cache[buf] = true
      end
      return true
    end
  end

  -- Cache negative result
  if config.get_value("performance.cache_enabled") then
    detection_cache[buf] = false
  end

  return false
end

--- Clear detection cache for a specific buffer
---@param buf number Buffer handle (0 = current buffer)
function M.clear_cache(buf)
  buf = utils.resolve_buf(buf)
  detection_cache[buf] = nil
end

--- Clear all detection caches
function M.clear_all_caches()
  detection_cache = {}
end

--- Setup all filetype detection mechanisms.
--- Uses a named augroup so repeated calls are idempotent.
function M.setup()
  local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })

  -- Secondary detection: override markdown -> myst when another plugin sets it
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function(args)
      local buf = args.buf
      if not utils.is_valid_buffer(buf) then
        return
      end
      if M.detect_myst(buf) then
        vim.bo[buf].filetype = "myst" -- luacheck: ignore 122
        utils.debug("Overriding markdown filetype to myst")
      end
    end,
    desc = "Override markdown filetype if MyST content detected",
  })

  -- Clear cache when buffer is written (content may have changed)
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.md",
    callback = function(args)
      M.clear_cache(args.buf)
      utils.debug("Cleared detection cache after buffer write")
    end,
    desc = "Clear MyST detection cache on buffer write",
  })

  -- Clear cache when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      M.clear_cache(args.buf)
    end,
    desc = "Clear MyST detection cache on buffer delete",
  })

  utils.debug("Filetype detection configured")
end

return M
