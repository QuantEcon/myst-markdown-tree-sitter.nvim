--- Configuration module for myst-markdown plugin
--- Handles user configuration and default settings
local M = {}

--- Default configuration
M.defaults = {
  -- Filetype detection settings
  detection = {
    scan_lines = 50,        -- Number of lines to scan for MyST patterns
    patterns = {
      code_cell = "^```{code%-cell}",           -- Code-cell directive
      myst_directive = "^```{[%w%-_:]+}",       -- Other MyST directives
      standalone_directive = "^{[%w%-_:]+}",    -- Standalone directives
    },
  },
  
  -- Performance settings
  performance = {
    defer_timeout = 50,     -- ms to defer highlighting setup
    refresh_wait = 100,     -- ms to wait during refresh
    cache_enabled = true,   -- Enable detection caching
  },
  
  -- Highlighting settings
  highlighting = {
    enabled = true,
    priority = 110,         -- Priority for highlight groups (if supported)
  },
  
  -- Supported languages for code-cell injection
  languages = {
    "python", "javascript", "bash", "r", "julia",
    "cpp", "c", "rust", "go", "typescript",
  },
  
  -- Language aliases (e.g., ipython -> python)
  language_aliases = {
    ipython = "python",
    ipython3 = "python",
    js = "javascript",
    sh = "bash",
  },
}

--- Current configuration (merged with user options)
M.config = {}

--- Merge user configuration with defaults
---@param opts table|nil User configuration options
---@return table Merged configuration
function M.merge(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", {}, M.defaults, opts)
  return M.config
end

--- Get current configuration
---@return table Current configuration
function M.get()
  return M.config
end

--- Get specific configuration value by path
---@param path string Dot-separated path (e.g., "detection.scan_lines")
---@return any Configuration value
function M.get_value(path)
  local keys = vim.split(path, ".", { plain = true })
  local value = M.config
  
  for _, key in ipairs(keys) do
    if type(value) == "table" and value[key] ~= nil then
      value = value[key]
    else
      return nil
    end
  end
  
  return value
end

--- Validate configuration
---@param config table Configuration to validate
---@return boolean, string|nil Valid, error message
function M.validate(config)
  -- Check detection.scan_lines is positive integer
  if config.detection and config.detection.scan_lines then
    if type(config.detection.scan_lines) ~= "number" or config.detection.scan_lines <= 0 then
      return false, "detection.scan_lines must be a positive number"
    end
  end
  
  -- Check performance timeouts are positive
  if config.performance then
    if config.performance.defer_timeout and 
       (type(config.performance.defer_timeout) ~= "number" or config.performance.defer_timeout < 0) then
      return false, "performance.defer_timeout must be a non-negative number"
    end
    if config.performance.refresh_wait and 
       (type(config.performance.refresh_wait) ~= "number" or config.performance.refresh_wait < 0) then
      return false, "performance.refresh_wait must be a non-negative number"
    end
  end
  
  return true, nil
end

return M
