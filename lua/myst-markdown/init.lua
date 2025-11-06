--- MyST Markdown Tree-sitter Plugin
--- Main entry point for the plugin
local M = {}

-- Import modules
local config = require("myst-markdown.config")
local utils = require("myst-markdown.utils")
local filetype = require("myst-markdown.filetype")
local highlighting = require("myst-markdown.highlighting")
local commands = require("myst-markdown.commands")

--- Plugin version
M.version = "0.2.1"

--- Setup function for the MyST markdown plugin
---@param opts table|nil User configuration options
function M.setup(opts)
  -- Validate Neovim version
  if not utils.check_version(0, 8, 0) then
    utils.error("MyST Markdown plugin requires Neovim >= 0.8.0")
    return
  end
  
  -- Merge user configuration with defaults
  local valid, err = config.validate(opts or {})
  if not valid then
    utils.error("Invalid configuration: " .. err)
    return
  end
  
  config.merge(opts)
  utils.info("Configuration loaded")
  
  -- Setup filetype detection
  filetype.setup()
  
  -- Setup highlighting autocmd for myst filetype
  highlighting.setup_filetype_autocmd()
  
  -- Setup user commands
  commands.setup()
  
  utils.info("MyST Markdown plugin initialized (v" .. M.version .. ")")
end

-- Export sub-modules for advanced use
M.config = config
M.utils = utils
M.filetype = filetype
M.highlighting = highlighting
M.commands = commands

return M