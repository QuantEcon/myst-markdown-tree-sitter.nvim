--- Configuration module for myst-markdown plugin
--- Handles user configuration, defaults, and validation.
local M = {}

--- Default configuration
---
--- Supported languages for code-cell injection are defined in
--- queries/markdown/injections.scm and cannot be changed at runtime.
--- See the README for the full list of supported languages.
M.defaults = {
  -- Enable debug logging (shows verbose initialisation messages)
  debug = false,

  -- Filetype detection settings
  detection = {
    -- Number of lines to scan from the top of a buffer when deciding
    -- whether a .md file is MyST.
    scan_lines = 50,
    -- Lua patterns matched against each scanned line.
    patterns = {
      code_cell = "^```{code%-cell}", -- Code-cell directive
      myst_directive = "^```{[%w%-_:]+}", -- Other MyST directives
      standalone_directive = "^{[%w%-_:]+}", -- Standalone directives
    },
  },

  -- Performance settings
  performance = {
    cache_enabled = true, -- Enable detection caching
  },

  -- Highlighting settings
  highlighting = {
    enabled = true,
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
  if next(M.config) == nil then
    -- If setup() hasn't been called yet, return defaults as a safety net.
    return M.defaults
  end
  return M.config
end

--- Get specific configuration value by dot-separated path
---@param path string Dot-separated path (e.g., "detection.scan_lines")
---@return any Configuration value, or nil if not found
function M.get_value(path)
  local keys = vim.split(path, ".", { plain = true })
  local value = M.get()

  for _, key in ipairs(keys) do
    if type(value) == "table" and value[key] ~= nil then
      value = value[key]
    else
      return nil
    end
  end

  return value
end

--- Validate user-supplied configuration before merging
---@param user_config table Configuration to validate
---@return boolean, string|nil Valid, error message
function M.validate(user_config)
  if type(user_config) ~= "table" then
    return false, "configuration must be a table"
  end

  -- Validate debug flag
  if user_config.debug ~= nil and type(user_config.debug) ~= "boolean" then
    return false, "debug must be a boolean"
  end

  -- Validate detection.scan_lines
  if user_config.detection and user_config.detection.scan_lines then
    local sl = user_config.detection.scan_lines
    if type(sl) ~= "number" or sl <= 0 or sl ~= math.floor(sl) then
      return false, "detection.scan_lines must be a positive integer"
    end
  end

  -- Validate detection.patterns
  if user_config.detection and user_config.detection.patterns then
    local p = user_config.detection.patterns
    if type(p) ~= "table" then
      return false, "detection.patterns must be a table"
    end
    for key, val in pairs(p) do
      if type(val) ~= "string" then
        return false, "detection.patterns." .. key .. " must be a string"
      end
    end
  end

  -- Validate performance.cache_enabled
  if user_config.performance and user_config.performance.cache_enabled ~= nil then
    if type(user_config.performance.cache_enabled) ~= "boolean" then
      return false, "performance.cache_enabled must be a boolean"
    end
  end

  -- Validate highlighting.enabled
  if user_config.highlighting and user_config.highlighting.enabled ~= nil then
    if type(user_config.highlighting.enabled) ~= "boolean" then
      return false, "highlighting.enabled must be a boolean"
    end
  end

  return true, nil
end

return M
