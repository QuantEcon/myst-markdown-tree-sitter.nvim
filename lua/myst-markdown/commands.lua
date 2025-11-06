--- User commands module for MyST Markdown
local M = {}
local utils = require("myst-markdown.utils")
local config = require("myst-markdown.config")

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
  print("Myst highlight queries loaded: " .. tostring(myst_highlights ~= nil))
  print("Myst injection queries loaded: " .. tostring(myst_injections ~= nil))

  -- Check tree-sitter highlighting status
  local highlighter_info = "not active"
  local highlighter_errors = {}

  if has_treesitter then
    local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
    if ts_highlight_ok and ts_highlight then
      if ts_highlight.active then
        local ts_highlighter = ts_highlight.active[buf]
        if ts_highlighter then
          highlighter_info = "active"
          if ts_highlighter.tree then
            highlighter_info = highlighter_info .. " (has tree)"
          else
            table.insert(highlighter_errors, "missing tree")
          end
          if ts_highlighter.parser then
            highlighter_info = highlighter_info .. " (has parser)"
          else
            table.insert(highlighter_errors, "missing parser")
          end
        else
          table.insert(highlighter_errors, "no highlighter instance for buffer")
        end
      else
        table.insert(highlighter_errors, "ts_highlight.active is nil")
      end
    else
      table.insert(highlighter_errors, "failed to load nvim-treesitter.highlight")
    end
  else
    table.insert(highlighter_errors, "nvim-treesitter not available")
  end

  print("Tree-sitter highlighter: " .. highlighter_info)

  if #highlighter_errors > 0 then
    print("Highlighter issues: " .. table.concat(highlighter_errors, ", "))

    -- Provide diagnostic suggestions
    print("\nDiagnostic suggestions:")
    if filetype ~= "myst" then
      print("  - File may not be detected as MyST. Check for MyST directives like {code-cell}")
      print("  - Ensure file has .md extension and contains MyST content")
    end
    print("  - Ensure nvim-treesitter is properly installed")
    print("  - Ensure markdown parser is installed with :TSInstall markdown")
  end

  -- Check parser configs
  if has_treesitter then
    local parsers = require("nvim-treesitter.parsers")
    local parser_config = parsers.get_parser_configs()
    print("Parser configs available: " .. table.concat(vim.tbl_keys(parser_config), ", "))

    -- Check filetype mapping
    if parsers.filetype_to_parsername then
      local myst_parser = parsers.filetype_to_parsername.myst
      print("MyST filetype mapped to parser: " .. tostring(myst_parser))
    end
  end

  -- Check first few lines for MyST patterns
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

  if has_treesitter then
    local ts_highlight_ok, ts_highlight = pcall(require, "nvim-treesitter.highlight")
    if ts_highlight_ok and ts_highlight and ts_highlight.active and ts_highlight.active[buf] then
      print("✓ Tree-sitter highlighting active")
    else
      print("✗ Tree-sitter highlighting not active")
    end
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
  print("Version: 0.2.0")
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
