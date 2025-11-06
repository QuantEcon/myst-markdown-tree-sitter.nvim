-- Test for MyST pattern detection
-- Run with: nvim --headless -c "PlenaryBustedDirectory test/unit/ {minimal_init = 'test/minimal_init.lua'}"

describe("pattern detection", function()
  local detect_myst_patterns

  before_each(function()
    -- Helper function to detect MyST patterns
    detect_myst_patterns = function(lines)
      for _, line in ipairs(lines) do
        if
          line:match("^```{code%-cell}")
          or line:match("^```{[%w%-_]+}")
          or line:match("^{[%w%-_]+}")
        then
          return true
        end
      end
      return false
    end
  end)

  describe("code-cell detection", function()
    it("should detect simple code-cell", function()
      local lines = { "```{code-cell} python" }
      assert.is_true(detect_myst_patterns(lines))
    end)

    it("should detect code-cell without language", function()
      local lines = { "```{code-cell}" }
      assert.is_true(detect_myst_patterns(lines))
    end)

    it("should detect code-cell with ipython", function()
      local lines = { "```{code-cell} ipython" }
      assert.is_true(detect_myst_patterns(lines))
    end)

    it("should detect code-cell with javascript", function()
      local lines = { "```{code-cell} javascript" }
      assert.is_true(detect_myst_patterns(lines))
    end)

    it("should NOT detect regular code blocks", function()
      local lines = { "```python" }
      assert.is_false(detect_myst_patterns(lines))
    end)

    it("should NOT detect empty lines", function()
      local lines = { "" }
      assert.is_false(detect_myst_patterns(lines))
    end)

    it("should NOT detect regular text", function()
      local lines = { "This is just text" }
      assert.is_false(detect_myst_patterns(lines))
    end)
  end)

  describe("other MyST directives", function()
    it("should detect note directive", function()
      local lines = { "```{note}" }
      assert.is_true(detect_myst_patterns(lines))
    end)

    it("should detect warning directive", function()
      local lines = { "```{warning}" }
      assert.is_true(detect_myst_patterns(lines))
    end)

    it("should detect standalone directives", function()
      local lines = { "{directive}" }
      assert.is_true(detect_myst_patterns(lines))
    end)
  end)

  describe("edge cases", function()
    it("should handle multiple lines", function()
      local lines = {
        "# Title",
        "",
        "```{code-cell} python",
        "print('test')",
        "```",
      }
      assert.is_true(detect_myst_patterns(lines))
    end)

    it("should handle nil input", function()
      assert.is_false(detect_myst_patterns({}))
    end)

    it("should find pattern in middle of buffer", function()
      local lines = {
        "Line 1",
        "Line 2",
        "```{code-cell} python",
        "Line 4",
      }
      assert.is_true(detect_myst_patterns(lines))
    end)
  end)
end)
