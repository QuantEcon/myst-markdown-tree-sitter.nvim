-- Unit tests for MyST pattern detection
-- Tests the real filetype.detect_myst() and utils.matches_any() functions.

describe("pattern detection", function()
  local utils = require("myst-markdown.utils")
  local filetype = require("myst-markdown.filetype")
  local config = require("myst-markdown.config")

  before_each(function()
    -- Ensure config is initialised with defaults
    config.merge({})
    -- Clear detection cache between tests
    filetype.clear_all_caches()
  end)

  -- ----------------------------------------------------------------
  -- utils.matches_any
  -- ----------------------------------------------------------------
  describe("utils.matches_any", function()
    local patterns = {
      "^```{code%-cell}",
      "^```{[%w%-_:]+}",
      "^{[%w%-_:]+}",
    }

    it("should match code-cell directive", function()
      local ok = utils.matches_any("```{code-cell} python", patterns)
      assert.is_true(ok)
    end)

    it("should match generic MyST directive", function()
      local ok = utils.matches_any("```{note}", patterns)
      assert.is_true(ok)
    end)

    it("should match standalone directive", function()
      local ok = utils.matches_any("{directive}", patterns)
      assert.is_true(ok)
    end)

    it("should NOT match regular code blocks", function()
      local ok = utils.matches_any("```python", patterns)
      assert.is_false(ok)
    end)

    it("should NOT match plain text", function()
      local ok = utils.matches_any("This is just text", patterns)
      assert.is_false(ok)
    end)

    it("should NOT match empty string", function()
      local ok = utils.matches_any("", patterns)
      assert.is_false(ok)
    end)
  end)

  -- ----------------------------------------------------------------
  -- filetype.detect_myst (buffer-based detection)
  -- ----------------------------------------------------------------
  describe("filetype.detect_myst", function()
    local function make_buf(lines)
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      return buf
    end

    after_each(function()
      -- Wipe scratch buffers
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
      end
    end)

    it("should detect code-cell python", function()
      local buf = make_buf({ "```{code-cell} python", "print('hi')", "```" })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should detect code-cell ipython", function()
      local buf = make_buf({ "```{code-cell} ipython", "x = 1", "```" })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should detect code-cell without language", function()
      local buf = make_buf({ "```{code-cell}", "x = 1", "```" })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should detect note directive", function()
      local buf = make_buf({ "# Title", "", "```{note}", "text", "```" })
      assert.is_true(filetype.detect_myst(buf))
    end)

    it("should NOT detect regular markdown", function()
      local buf = make_buf({ "# Title", "", "```python", "print(1)", "```" })
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should NOT detect empty buffer", function()
      local buf = make_buf({})
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should respect scan_lines limit", function()
      -- Place MyST directive on line 5 (within default scan_lines = 50)
      local lines = {}
      for i = 1, 4 do
        lines[i] = "Line " .. i
      end
      lines[5] = "```{code-cell} python"
      local buf = make_buf(lines)
      assert.is_true(filetype.detect_myst(buf))

      -- Now set scan_lines = 3 so line 5 is out of range
      config.merge({ detection = { scan_lines = 3 } })
      filetype.clear_all_caches()
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should cache results", function()
      config.merge({ performance = { cache_enabled = true } })
      local buf = make_buf({ "```{code-cell} python" })

      -- First call populates cache
      assert.is_true(filetype.detect_myst(buf))
      -- Remove the content but cache should still return true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "no myst here" })
      assert.is_true(filetype.detect_myst(buf))

      -- After clearing cache, should re-scan
      filetype.clear_cache(buf)
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should skip cache when disabled", function()
      config.merge({ performance = { cache_enabled = false } })
      local buf = make_buf({ "```{code-cell} python" })
      assert.is_true(filetype.detect_myst(buf))

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "no myst here" })
      -- Without caching, the re-scan should pick up the changed content
      assert.is_false(filetype.detect_myst(buf))
    end)
  end)

  -- ----------------------------------------------------------------
  -- Language variations
  -- ----------------------------------------------------------------
  describe("language variants", function()
    local function make_buf(lines)
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      return buf
    end

    after_each(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
      end
    end)

    local languages = {
      "python",
      "python3",
      "ipython",
      "ipython3",
      "javascript",
      "bash",
      "r",
      "julia",
      "cpp",
      "rust",
      "go",
      "typescript",
    }

    for _, lang in ipairs(languages) do
      it("should detect code-cell " .. lang, function()
        local buf = make_buf({ "```{code-cell} " .. lang, "code", "```" })
        assert.is_true(filetype.detect_myst(buf))
      end)
    end
  end)
end)
