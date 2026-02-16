--- MyST Markdown Tree-sitter Plugin
--- Main entry point for the plugin
local M = {}

-- Import modules
local config = require("myst-markdown.config")
local utils = require("myst-markdown.utils")
local filetype = require("myst-markdown.filetype")
local highlighting = require("myst-markdown.highlighting")
local commands = require("myst-markdown.commands")

--- Plugin version (single source of truth in version.lua)
M.version = require("myst-markdown.version")

--- Whether setup() has already been called at least once.
local _setup_done = false

--- Setup function for the MyST markdown plugin.
--- Can be called multiple times safely; autocmds are recreated via augroups.
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

  -- Propagate the debug flag to utils so we avoid pcall(require) on every
  -- debug() call.
  utils._debug_enabled = config.get_value("debug") or false

  utils.debug("Configuration loaded")

  -- Setup filetype detection (idempotent via augroup)
  filetype.setup()

  -- Setup highlighting autocmd for myst filetype (idempotent via augroup)
  highlighting.setup_filetype_autocmd()

  -- Setup user commands (idempotent — nvim_create_user_command overwrites)
  commands.setup()

  _setup_done = true
  utils.debug("MyST Markdown plugin initialized (v" .. M.version .. ")")
end

--- Check whether setup() has been called
---@return boolean
function M.is_setup()
  return _setup_done
end

-- Export sub-modules for advanced use
M.config = config
M.utils = utils
M.filetype = filetype
M.highlighting = highlighting
M.commands = commands

return M
