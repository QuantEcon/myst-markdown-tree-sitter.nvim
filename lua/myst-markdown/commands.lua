--- User commands module for MyST Markdown
local M = {}
local utils = require("myst-markdown.utils")
local config = require("myst-markdown.config")
local version = require("myst-markdown.version")

--- Check if tree-sitter highlighting is actually working for a buffer.
--- Uses multiple methods since nvim-treesitter internal state can be unreliable.
---@param buf number Buffer handle
---@return boolean has_active_parser, boolean nvim_ts_active
local function check_ts_highlighting_active(buf)
  buf = utils.resolve_buf(buf)

  -- Method 1: Check if vim.treesitter has an active parser
  local has_active_parser = false
  local filetype = vim.bo[buf].filetype
  local lang = filetype == "myst" and "markdown" or filetype

  local parser_ok, parser = pcall(vim.treesitter.get_parser, buf, lang)
  if parser_ok and parser then
    has_active_parser = true
  end

  -- Method 2: Check nvim-treesitter's internal state (not always reliable)
  local nvim_ts_active = false
  local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
  if ts_highlight_ok and ts_highlight and ts_highlight.active and ts_highlight.active[buf] then
    nvim_ts_active = true
  end

  return has_active_parser, nvim_ts_active
end

--- Show comprehensive MyST debugging information
function M.debug_myst()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype
  local has_treesitter = utils.has_treesitter()
  local parser_info = "not available"

  if has_treesitter then
    local parsers = require("nvim-treesitter.parsers")
    local lang = parsers.get_buf_lang(buf)
    parser_info = lang or "no parser found"
  end

  local lines_out = {
    "=== MyST Debug Information ===",
    "Current filetype: " .. filetype,
    "Tree-sitter available: " .. tostring(has_treesitter),
    "Active parser: " .. parser_info,
  }

  -- Check if myst queries exist
  local myst_highlights = utils.ts_get_query("markdown", "highlights")
  local myst_injections = utils.ts_get_query("markdown", "injections")
  table.insert(lines_out, "Markdown highlight queries loaded: " .. tostring(myst_highlights ~= nil))
  table.insert(lines_out, "Markdown injection queries loaded: " .. tostring(myst_injections ~= nil))

  -- Check tree-sitter highlighting status
  local has_active_parser, nvim_ts_active = check_ts_highlighting_active(buf)

  table.insert(lines_out, "")
  table.insert(lines_out, "Highlighting Status:")
  if has_active_parser then
    table.insert(lines_out, "  ✓ Tree-sitter parser active for buffer")
  else
    table.insert(lines_out, "  ✗ No tree-sitter parser for buffer")
  end

  if nvim_ts_active then
    table.insert(lines_out, "  ✓ nvim-treesitter highlighter registered")
  else
    table.insert(lines_out, "  ⚠ nvim-treesitter internal state shows inactive")
    table.insert(lines_out, "    (This is often a false negative — highlighting may still work)")
  end

  -- Overall assessment
  if has_active_parser and myst_injections then
    table.insert(lines_out, "")
    table.insert(
      lines_out,
      "✓ Highlighting should be working (parser + injection queries loaded)"
    )
  elseif not has_active_parser then
    table.insert(lines_out, "")
    table.insert(lines_out, "✗ Highlighting NOT working — no active parser")
    table.insert(lines_out, "")
    table.insert(lines_out, "Diagnostic suggestions:")
    table.insert(lines_out, "  - Ensure nvim-treesitter is properly installed")
    table.insert(lines_out, "  - Ensure markdown parser is installed with :TSInstall markdown")
    table.insert(lines_out, "  - Try reopening the file")
  end

  -- Check parser configs
  if has_treesitter then
    local parsers = require("nvim-treesitter.parsers")
    if parsers.filetype_to_parsername then
      local myst_parser = parsers.filetype_to_parsername.myst
      table.insert(lines_out, "")
      table.insert(lines_out, "MyST filetype mapped to parser: " .. tostring(myst_parser))
    end
  end

  -- Check first few lines for MyST patterns
  table.insert(lines_out, "")
  local buf_lines = utils.get_buf_lines(buf, 0, 10) or {}
  local has_myst_patterns = false

  for i, line in ipairs(buf_lines) do
    if line:match("^```{code%-cell}") or line:match("^```{[%w%-_]+}") then
      table.insert(lines_out, "MyST pattern found on line " .. i .. ": " .. line)
      has_myst_patterns = true
    end
  end

  if not has_myst_patterns then
    table.insert(lines_out, "No MyST patterns found in first 10 lines")
  end

  -- Show configuration
  table.insert(lines_out, "")
  table.insert(lines_out, "Configuration:")
  table.insert(lines_out, "  Scan lines: " .. tostring(config.get_value("detection.scan_lines")))
  table.insert(
    lines_out,
    "  Cache enabled: " .. tostring(config.get_value("performance.cache_enabled"))
  )

  table.insert(lines_out, "Buffer name: " .. (vim.api.nvim_buf_get_name(buf) or "unnamed"))
  table.insert(lines_out, "=== End Debug Info ===")

  print(table.concat(lines_out, "\n"))
end

--- Show quick MyST status check
function M.status_myst()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype

  local lines_out = { "=== MyST Status ===" }
  table.insert(lines_out, "Filetype: " .. filetype)

  if filetype == "myst" then
    table.insert(lines_out, "✓ File detected as MyST")
  else
    table.insert(lines_out, "✗ File not detected as MyST")
  end

  -- Check highlighting using reliable method
  local has_active_parser, _ = check_ts_highlighting_active(buf)
  local myst_injections = utils.ts_get_query("markdown", "injections")

  if has_active_parser and myst_injections then
    table.insert(lines_out, "✓ Tree-sitter highlighting ready")
  elseif utils.has_treesitter() then
    table.insert(lines_out, "⚠ Tree-sitter available but parser may not be active")
  else
    table.insert(lines_out, "✗ nvim-treesitter not available")
  end

  -- Check for MyST content
  local filetype_mod = require("myst-markdown.filetype")
  local has_myst_content = filetype_mod.detect_myst(buf)

  if has_myst_content then
    table.insert(lines_out, "✓ MyST content detected in buffer")
  else
    table.insert(lines_out, "? No obvious MyST content found (check full file)")
  end

  table.insert(lines_out, "==================")
  print(table.concat(lines_out, "\n"))
end

--- Show plugin information
function M.info()
  local nvim_version = vim.version()
  local nvim_str =
    string.format("%d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch)

  local lines_out = {
    "=== MyST Markdown Plugin ===",
    "Version: " .. version,
    "Neovim version: " .. nvim_str,
    "Tree-sitter available: " .. tostring(utils.has_treesitter()),
    "Markdown parser available: " .. tostring(utils.has_parser("markdown")),
    "",
    "Commands:",
    "  :MystDebug  — Show detailed debugging information",
    "  :MystStatus — Show quick status check",
    "  :MystInfo   — Show this information",
    "",
    "Configuration:",
    "  See :help myst-markdown for configuration options",
    "===========================",
  }
  print(table.concat(lines_out, "\n"))
end

--- Setup all user commands.
--- Safe to call multiple times — nvim_create_user_command overwrites existing
--- commands with the same name.
function M.setup()
  vim.api.nvim_create_user_command("MystDebug", function()
    M.debug_myst()
  end, { desc = "Show MyST debugging information" })

  vim.api.nvim_create_user_command("MystStatus", function()
    M.status_myst()
  end, { desc = "Show quick MyST status check" })

  vim.api.nvim_create_user_command("MystInfo", function()
    M.info()
  end, { desc = "Show MyST plugin information" })

  utils.debug("User commands registered")
end

return M
