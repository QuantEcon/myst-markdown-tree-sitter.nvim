--- Filetype detection module for MyST Markdown
local M = {}
local utils = require("myst-markdown.utils")
local config = require("myst-markdown.config")

--- Cache for filetype detection results
--- Key: buffer number, Value: boolean (is_myst)
local detection_cache = {}

--- Detect if buffer contains MyST patterns
---@param buf number Buffer handle
---@return boolean Whether buffer contains MyST content
function M.detect_myst(buf)
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
      -- Cache result
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
---@param buf number Buffer handle
function M.clear_cache(buf)
  detection_cache[buf] = nil
end

--- Clear all detection caches
function M.clear_all_caches()
  detection_cache = {}
end

--- Setup primary filetype detection on file read
function M.setup_primary_detection()
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.md",
    callback = function(args)
      local buf = args.buf

      if not utils.is_valid_buffer(buf) then
        return
      end

      if M.detect_myst(buf) then
        vim.bo[buf].filetype = "myst" -- luacheck: ignore 122
        utils.debug("Detected MyST file on BufRead/BufNewFile")
      end
    end,
    desc = "Detect MyST markdown files on open",
  })
end

--- Setup secondary filetype detection to override markdown filetype
function M.setup_secondary_detection()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(args)
      local buf = args.buf

      if not utils.is_valid_buffer(buf) then
        return
      end

      if M.detect_myst(buf) then
        vim.bo[buf].filetype = "myst" -- luacheck: ignore 122
        utils.debug("Overriding markdown filetype to myst")

        -- Defer highlighting setup
        local defer_timeout = config.get_value("performance.defer_timeout") or 50
        utils.defer(function()
          local highlighting = require("myst-markdown.highlighting")
          highlighting.setup()
        end, defer_timeout)
      end
    end,
    desc = "Override markdown filetype if MyST content detected",
  })
end

--- Setup buffer change detection to clear cache
function M.setup_cache_invalidation()
  -- Clear cache when buffer is written (content may have changed)
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.md",
    callback = function(args)
      M.clear_cache(args.buf)
      utils.debug("Cleared detection cache after buffer write")
    end,
    desc = "Clear MyST detection cache on buffer write",
  })

  -- Clear cache when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(args)
      M.clear_cache(args.buf)
    end,
    desc = "Clear MyST detection cache on buffer delete",
  })
end

--- Setup all filetype detection mechanisms
function M.setup()
  M.setup_primary_detection()
  M.setup_secondary_detection()
  M.setup_cache_invalidation()
  utils.info("Filetype detection configured")
end

return M
