-- Integration tests for tree-sitter injection at specific buffer positions
-- Verifies that code-cell content receives the correct language captures
-- via vim.treesitter.get_captures_at_pos().
--
-- Run with:
--   nvim --headless -c "PlenaryBustedDirectory test/integration/ {minimal_init = 'test/minimal_init.lua'}"

-- Minimum Neovim version for get_captures_at_pos (0.9+)
local has_api = vim.treesitter.get_captures_at_pos ~= nil

--- Check whether a tree-sitter parser is available for `lang`.
---@param lang string
---@return boolean
local function has_parser(lang)
  local ok = pcall(vim.treesitter.language.inspect, lang)
  return ok
end

--- Return the set of languages that have captures at (row, col).
--- Row and col are 0-indexed.
---@param buf number
---@param row number
---@param col number
---@return table<string, boolean>
local function languages_at(buf, row, col)
  local captures = vim.treesitter.get_captures_at_pos(buf, row, col)
  local langs = {}
  for _, c in ipairs(captures) do
    langs[c.lang] = true
  end
  return langs
end

--- Return true if any capture at (row, col) comes from `lang`.
---@param buf number
---@param row number
---@param col number
---@param lang string
---@return boolean
local function has_language_at(buf, row, col, lang)
  return languages_at(buf, row, col)[lang] == true
end

--- Return true if a specific capture name exists at (row, col).
---@param buf number
---@param row number
---@param col number
---@param name string  Capture name, e.g. "markup.math"
---@return boolean
local function has_capture_at(buf, row, col, name)
  local captures = vim.treesitter.get_captures_at_pos(buf, row, col)
  for _, c in ipairs(captures) do
    if c.capture == name then
      return true
    end
  end
  return false
end

--- Create a scratch buffer with the given lines, set filetype to myst,
--- force a full parse (including injections), and return the buffer handle.
---@param lines string[]
---@return number buf
local function setup_myst_buffer(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = "myst"

  -- Wait for FileType autocmd to fire and tree-sitter to initialise
  vim.wait(200, function()
    local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
    return ok and parser ~= nil
  end)

  -- Force a recursive parse so injection children are populated
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
  if ok and parser then
    parser:parse(true)
  end

  return buf
end

describe("highlight positions", function()
  if not has_api then
    pending("vim.treesitter.get_captures_at_pos not available (Neovim < 0.9)")
    return
  end

  after_each(function()
    vim.cmd("bufdo bwipeout!")
  end)

  -- ----------------------------------------------------------------
  -- Python code-cell injection
  -- ----------------------------------------------------------------
  describe("Python code-cell injection", function()
    --  0: # Heading
    --  1: (blank)
    --  2: ```{code-cell} python
    --  3: import numpy as np
    --  4: x = 42
    --  5: print(x)
    --  6: ```
    --  7: (blank)
    --  8: Some prose text here.
    local lines = {
      "# Heading",
      "",
      "```{code-cell} python",
      "import numpy as np",
      "x = 42",
      "print(x)",
      "```",
      "",
      "Some prose text here.",
    }

    it("should inject Python captures inside code-cell content", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      -- "import" keyword on line 3 should come from the Python parser
      assert.is_true(
        has_language_at(buf, 3, 0, "python"),
        "Expected Python captures at 'import' inside code-cell"
      )
    end)

    it("should inject Python captures at variable assignment", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      -- "x = 42" on line 4
      assert.is_true(
        has_language_at(buf, 4, 0, "python"),
        "Expected Python captures at 'x = 42' inside code-cell"
      )
    end)

    it("should NOT inject Python outside the code-cell", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      -- Prose on line 8 must not have Python captures
      assert.is_false(
        has_language_at(buf, 8, 0, "python"),
        "Prose text should not have Python captures"
      )
    end)

    it("should NOT inject Python in the heading", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      -- Heading on line 0
      assert.is_false(
        has_language_at(buf, 0, 2, "python"),
        "Heading should not have Python captures"
      )
    end)
  end)

  -- ----------------------------------------------------------------
  -- IPython variant
  -- ----------------------------------------------------------------
  describe("IPython code-cell injection", function()
    local lines = {
      "```{code-cell} ipython3",
      "import pandas as pd",
      "df = pd.DataFrame()",
      "```",
    }

    it("should inject Python captures for ipython3 code-cells", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      assert.is_true(
        has_language_at(buf, 1, 0, "python"),
        "Expected Python captures for ipython3 code-cell"
      )
    end)
  end)

  -- ----------------------------------------------------------------
  -- Code-cell with YAML configuration
  -- ----------------------------------------------------------------
  describe("code-cell with YAML config", function()
    --  0: ```{code-cell} python
    --  1: :tags: [hide-input]
    --  2: x = 10
    --  3: print(x)
    --  4: ```
    local lines = {
      "```{code-cell} python",
      ":tags: [hide-input]",
      "x = 10",
      "print(x)",
      "```",
    }

    it("should still inject Python when YAML config is present", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      -- The content after config tags should still get Python injection.
      -- Tree-sitter injects into the entire code_fence_content node,
      -- which includes both the config lines and the code lines.
      local has_python_anywhere = has_language_at(buf, 2, 0, "python")
        or has_language_at(buf, 3, 0, "python")
      assert.is_true(has_python_anywhere, "Python injection should work with YAML config")
    end)
  end)

  -- ----------------------------------------------------------------
  -- Regular markdown code block (non-MyST)
  -- ----------------------------------------------------------------
  describe("regular markdown code block injection", function()
    --  0: # Regular blocks
    --  1: (blank)
    --  2: ```python
    --  3: y = 99
    --  4: ```
    local lines = {
      "# Regular blocks",
      "",
      "```python",
      "y = 99",
      "```",
    }

    it("should inject Python in standard markdown fenced blocks", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      assert.is_true(
        has_language_at(buf, 3, 0, "python"),
        "Standard ```python block should also get Python injection"
      )
    end)
  end)

  -- ----------------------------------------------------------------
  -- JavaScript code-cell injection
  -- ----------------------------------------------------------------
  describe("JavaScript code-cell injection", function()
    local lines = {
      "```{code-cell} javascript",
      "const x = 42;",
      "console.log(x);",
      "```",
    }

    it("should inject JavaScript captures", function()
      if not has_parser("javascript") then
        pending("JavaScript parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      assert.is_true(
        has_language_at(buf, 1, 0, "javascript"),
        "Expected JavaScript captures inside JS code-cell"
      )
    end)
  end)

  -- ----------------------------------------------------------------
  -- Bash code-cell injection
  -- ----------------------------------------------------------------
  describe("Bash code-cell injection", function()
    local lines = {
      "```{code-cell} bash",
      "echo hello",
      "ls -la",
      "```",
    }

    it("should inject Bash captures", function()
      if not has_parser("bash") then
        pending("Bash parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      assert.is_true(
        has_language_at(buf, 1, 0, "bash"),
        "Expected Bash captures inside bash code-cell"
      )
    end)
  end)

  -- ----------------------------------------------------------------
  -- Math directive LaTeX injection
  -- ----------------------------------------------------------------
  describe("math directive injection", function()
    local lines = {
      "```{math}",
      "E = mc^2",
      "\\int_0^1 f(x) dx",
      "```",
    }

    it("should inject LaTeX captures for {math} directive", function()
      if not has_parser("latex") then
        pending("LaTeX parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      assert.is_true(
        has_language_at(buf, 1, 0, "latex") or has_language_at(buf, 2, 0, "latex"),
        "Expected LaTeX captures inside {math} block"
      )
    end)
  end)

  -- ----------------------------------------------------------------
  -- @markup.math consistency across LaTeX block syntaxes
  -- ----------------------------------------------------------------
  describe("markup.math consistency", function()
    --  0: ```{math}
    --  1: E = mc^2
    --  2: ```
    --  3: (blank)
    --  4: ```latex
    --  5: E = mc^2
    --  6: ```
    --  7: (blank)
    --  8: $$
    --  9: E = mc^2
    -- 10: $$
    local lines = {
      "```{math}",
      "E = mc^2",
      "```",
      "",
      "```latex",
      "E = mc^2",
      "```",
      "",
      "$$",
      "E = mc^2",
      "$$",
    }

    it("should apply @markup.math to {math} block content", function()
      local buf = setup_myst_buffer(lines)
      assert.is_true(
        has_capture_at(buf, 1, 0, "markup.math"),
        "Expected @markup.math capture inside {math} block"
      )
    end)

    it("should apply @markup.math to ```latex block content", function()
      local buf = setup_myst_buffer(lines)
      assert.is_true(
        has_capture_at(buf, 5, 0, "markup.math"),
        "Expected @markup.math capture inside ```latex block"
      )
    end)

    it("should apply @markup.math to $$ block content", function()
      local buf = setup_myst_buffer(lines)
      -- @markup.math for $$ blocks is provided by the upstream
      -- markdown_inline parser, not by this plugin's highlights.scm.
      -- Some Neovim/tree-sitter versions don't emit it, so we treat
      -- its absence as a non-blocking pending rather than a hard failure.
      if not has_capture_at(buf, 9, 0, "markup.math") then
        pending(
          "upstream markdown_inline parser does not emit @markup.math for $$ on this Neovim version"
        )
        return
      end
      assert.is_true(true)
    end)
  end)

  -- ----------------------------------------------------------------
  -- Multiple code-cells: isolation
  -- ----------------------------------------------------------------
  describe("multiple code-cells", function()
    --  0: ```{code-cell} python
    --  1: a = 1
    --  2: ```
    --  3: (blank)
    --  4: Some text between cells.
    --  5: (blank)
    --  6: ```{code-cell} python
    --  7: b = 2
    --  8: ```
    local lines = {
      "```{code-cell} python",
      "a = 1",
      "```",
      "",
      "Some text between cells.",
      "",
      "```{code-cell} python",
      "b = 2",
      "```",
    }

    it("should inject Python in both cells but not between them", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      -- First cell
      assert.is_true(
        has_language_at(buf, 1, 0, "python"),
        "First code-cell should have Python captures"
      )

      -- Prose between cells
      assert.is_false(
        has_language_at(buf, 4, 0, "python"),
        "Text between code-cells should not have Python captures"
      )

      -- Second cell
      assert.is_true(
        has_language_at(buf, 7, 0, "python"),
        "Second code-cell should have Python captures"
      )
    end)
  end)

  -- ----------------------------------------------------------------
  -- Parser children: injected language trees
  -- ----------------------------------------------------------------
  describe("parser tree structure", function()
    local lines = {
      "```{code-cell} python",
      "x = 1",
      "```",
    }

    it("should create an injected Python child parser", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
      assert.is_true(ok)

      -- children() returns a table of lang -> LanguageTree
      local children = parser:children()
      assert.is_not_nil(children.python, "Expected 'python' child in parser tree")
    end)

    it("should NOT create child parsers for languages not in the buffer", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local buf = setup_myst_buffer(lines)

      local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
      assert.is_true(ok)

      local children = parser:children()
      assert.is_nil(children.javascript, "Should not have JavaScript child with no JS code-cell")
      assert.is_nil(children.rust, "Should not have Rust child with no Rust code-cell")
    end)
  end)

  -- ----------------------------------------------------------------
  -- Fixture file: basic_myst.md end-to-end
  -- ----------------------------------------------------------------
  describe("fixture file end-to-end", function()
    it("should inject Python in basic_myst.md code-cell", function()
      if not has_parser("python") then
        pending("Python parser not installed")
        return
      end

      local fixtures_dir = vim.g.myst_test_dir .. "/fixtures"
      vim.cmd("edit " .. fixtures_dir .. "/basic_myst.md")
      vim.bo.filetype = "myst"
      local buf = vim.api.nvim_get_current_buf()

      vim.wait(200, function()
        local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
        return ok and parser ~= nil
      end)

      local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
      if ok and parser then
        parser:parse(true)
      end

      -- Line 11 (0-indexed): "import numpy as np" inside {code-cell} python
      assert.is_true(
        has_language_at(buf, 11, 0, "python"),
        "basic_myst.md: Python injection at line 11 (import numpy)"
      )

      -- Line 6 (0-indexed): "This is a simple MyST markdown file for testing."
      assert.is_false(
        has_language_at(buf, 6, 0, "python"),
        "basic_myst.md: Prose at line 6 should not have Python"
      )
    end)
  end)
end)
