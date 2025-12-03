--- User commands module for MyST Markdown
local M = {}
local utils = require("myst-markdown.utils")
local config = require("myst-markdown.config")
local version = require("myst-markdown.version")

--- Check if tree-sitter highlighting is actually working for a buffer
--- This uses multiple methods since nvim-treesitter internal state is unreliable
local function check_ts_highlighting_active(buf)
  -- Method 1: Check if vim.treesitter has an active parser for this buffer
  -- For myst filetype, we need to explicitly request the markdown parser
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

  print("=== MyST Debug Information ===")
  print("Current filetype: " .. filetype)
  print("Tree-sitter available: " .. tostring(has_treesitter))
  print("Active parser: " .. parser_info)

  -- Check if myst queries exist
  local myst_highlights = vim.treesitter.query.get("markdown", "highlights")
  local myst_injections = vim.treesitter.query.get("markdown", "injections")
  print("Markdown highlight queries loaded: " .. tostring(myst_highlights ~= nil))
  print("Markdown injection queries loaded: " .. tostring(myst_injections ~= nil))

  -- Check tree-sitter highlighting status using multiple methods
  local has_active_parser, nvim_ts_active = check_ts_highlighting_active(buf)

  print("")
  print("Highlighting Status:")
  if has_active_parser then
    print("  ✓ Tree-sitter parser active for buffer")
  else
    print("  ✗ No tree-sitter parser for buffer")
  end

  if nvim_ts_active then
    print("  ✓ nvim-treesitter highlighter registered")
  else
    print("  ⚠ nvim-treesitter internal state shows inactive")
    print("    (This is often a false negative - highlighting may still work)")
  end

  -- Overall assessment
  if has_active_parser and myst_injections then
    print("")
    print("✓ Highlighting should be working (parser + injection queries loaded)")
  elseif not has_active_parser then
    print("")
    print("✗ Highlighting NOT working - no active parser")
    print("\nDiagnostic suggestions:")
    print("  - Ensure nvim-treesitter is properly installed")
    print("  - Ensure markdown parser is installed with :TSInstall markdown")
    print("  - Try reopening the file")
  end

  -- Check parser configs
  if has_treesitter then
    local parsers = require("nvim-treesitter.parsers")

    -- Check filetype mapping
    if parsers.filetype_to_parsername then
      local myst_parser = parsers.filetype_to_parsername.myst
      print("\nMyST filetype mapped to parser: " .. tostring(myst_parser))
    end
  end

  -- Check first few lines for MyST patterns
  print("")
  local lines = utils.get_buf_lines(buf, 0, 10) or {}
  local has_myst_patterns = false

  for i, line in ipairs(lines) do
    if line:match("^```{code%-cell}") or line:match("^```{[%w%-_]+}") then
      print("MyST pattern found on line " .. i .. ": " .. line)
      has_myst_patterns = true
    end
  end

  if not has_myst_patterns then
    print("No MyST patterns found in first 10 lines")
  end

  -- Show configuration
  print("\nConfiguration:")
  print("  Scan lines: " .. config.get_value("detection.scan_lines"))
  print("  Cache enabled: " .. tostring(config.get_value("performance.cache_enabled")))

  print("Buffer name: " .. (vim.api.nvim_buf_get_name(buf) or "unnamed"))
  print("=== End Debug Info ===")
end

--- Show quick MyST status check
function M.status_myst()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype
  local has_treesitter = utils.has_treesitter()

  print("=== MyST Status ===")
  print("Filetype: " .. filetype)

  if filetype == "myst" then
    print("✓ File detected as MyST")
  else
    print("✗ File not detected as MyST")
  end

  -- Check highlighting using reliable method
  local has_active_parser, _ = check_ts_highlighting_active(buf)
  local myst_injections = vim.treesitter.query.get("markdown", "injections")

  if has_active_parser and myst_injections then
    print("✓ Tree-sitter highlighting ready")
  elseif has_treesitter then
    print("⚠ Tree-sitter available but parser may not be active")
  else
    print("✗ nvim-treesitter not available")
  end

  -- Check for MyST content
  local filetype_mod = require("myst-markdown.filetype")
  local has_myst_content = filetype_mod.detect_myst(buf)

  if has_myst_content then
    print("✓ MyST content detected in buffer")
  else
    print("? No obvious MyST content found (check full file)")
  end

  print("==================")
end

--- Show plugin information
function M.info()
  print("=== MyST Markdown Plugin ===")
  print("Version: " .. version)
  print("Neovim version: " .. vim.fn.execute("version"):match("NVIM v([%d.]+)"))
  print("Tree-sitter available: " .. tostring(utils.has_treesitter()))
  print("Markdown parser available: " .. tostring(utils.has_parser("markdown")))
  print("\nCommands:")
  print("  :MystDebug  - Show detailed debugging information")
  print("  :MystStatus - Show quick status check")
  print("  :MystInfo   - Show this information")
  print("\nConfiguration:")
  print("  See :help myst-markdown for configuration options")
  print("===========================")
end

--- Setup all user commands
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
