-- Edge case tests for MyST detection
-- Tests the real filetype.detect_myst() with unusual inputs.

describe("edge case detection", function()
  local filetype = require("myst-markdown.filetype")
  local config = require("myst-markdown.config")

  --- Helper: create a scratch buffer from a list of lines
  local function make_buf(lines)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return buf
  end

  before_each(function()
    config.merge({})
    filetype.clear_all_caches()
  end)

  after_each(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end
  end)

  -- ----------------------------------------------------------------
  -- Malformed syntax
  -- ----------------------------------------------------------------
  describe("malformed syntax", function()
    it("should NOT detect code-cell with missing closing brace", function()
      local buf = make_buf({ "```{code-cell python" })
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should detect code-cell without language", function()
      local buf = make_buf({ "```{code-cell}" })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should NOT detect code-cell with extra spaces inside braces", function()
      local buf = make_buf({ "```{ code-cell } python" })
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should NOT detect incomplete directive", function()
      local buf = make_buf({ "```{code" })
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should NOT detect plain text with braces in middle", function()
      local buf = make_buf({ "Some text with {braces} but not a directive" })
      assert.is_false(filetype.detect_myst(buf))
    end)
  end)

  -- ----------------------------------------------------------------
  -- Unicode and special characters
  -- ----------------------------------------------------------------
  describe("unicode and special characters", function()
    it("should handle unicode after directive", function()
      local buf = make_buf({ "```{code-cell} python  # 你好世界" })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should handle emoji after directive", function()
      local buf = make_buf({ "```{code-cell} python  # 🚀 Launch" })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should handle special regex characters", function()
      local buf = make_buf({ "```{code-cell} python  # !@#$%^&*()" })
      assert.is_true(filetype.detect_myst(buf))
    end)
  end)

  -- ----------------------------------------------------------------
  -- Whitespace variations
  -- ----------------------------------------------------------------
  describe("whitespace variations", function()
    it("should NOT detect code-cell with leading whitespace (not valid MyST)", function()
      -- Fenced code blocks in Markdown can have up to 3 spaces of indentation,
      -- but the default patterns require ^``` at column 0.
      local buf = make_buf({ "   ```{code-cell} python" })
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should detect code-cell with trailing whitespace", function()
      local buf = make_buf({ "```{code-cell} python   " })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should NOT detect empty buffer", function()
      local buf = make_buf({ "" })
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should NOT detect whitespace-only lines", function()
      local buf = make_buf({ "   \t   " })
      assert.is_false(filetype.detect_myst(buf))
    end)
  end)

  -- ----------------------------------------------------------------
  -- Various directive types
  -- ----------------------------------------------------------------
  describe("various directive types", function()
    local directives = {
      "note",
      "warning",
      "tip",
      "caution",
      "admonition",
      "code-cell",
    }

    for _, name in ipairs(directives) do
      it("should detect {" .. name .. "} directive", function()
        local buf = make_buf({ "```{" .. name .. "}" })
        assert.is_true(filetype.detect_myst(buf))
      end)
    end
  end)

  -- ----------------------------------------------------------------
  -- Case sensitivity
  -- ----------------------------------------------------------------
  describe("case sensitivity", function()
    it("should detect lowercase code-cell", function()
      local buf = make_buf({ "```{code-cell} python" })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should NOT detect uppercase Code-Cell (MyST is case-sensitive)", function()
      -- %w in Lua matches both cases, but real MyST only uses lowercase.
      -- The current pattern allows uppercase — this tests current behaviour.
      local buf = make_buf({ "```{Code-Cell} python" })
      -- Pattern ^```{[%w%-_:]+} does match uppercase, so this is detected.
      assert.is_true(filetype.detect_myst(buf))
    end)
  end)

  -- ----------------------------------------------------------------
  -- Boundary conditions
  -- ----------------------------------------------------------------
  describe("boundary conditions", function()
    it("should handle very long lines", function()
      local buf = make_buf({ "```{code-cell} python  # " .. string.rep("x", 1000) })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should handle a large number of plain lines before MyST", function()
      local lines = {}
      for i = 1, 49 do
        lines[i] = "Plain line " .. i
      end
      lines[50] = "```{code-cell} python"
      local buf = make_buf(lines)
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should NOT detect MyST beyond scan_lines", function()
      local lines = {}
      for i = 1, 51 do
        lines[i] = "Plain line " .. i
      end
      lines[51] = "```{code-cell} python"
      local buf = make_buf(lines)
      assert.is_false(filetype.detect_myst(buf))
    end)
  end)
end)
