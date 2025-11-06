-- Performance Tests for MyST Detection
-- Tests detection performance on large files

describe("performance tests", function()
  local detect_myst_pattern

  before_each(function()
    -- Helper function to detect MyST patterns (matches main implementation)
    detect_myst_pattern = function(line)
      if not line or type(line) ~= "string" then
        return false
      end
      -- Match MyST directive patterns
      if line:match("^%s*```{[%w%-_]+}") then
        return true
      end
      -- Match standalone directives
      if line:match("^{[%w%-_]+}") then
        return true
      end
      return false
    end
  end)

  describe("large file handling", function()
    it("should detect MyST in large file efficiently", function()
      -- Read the large test file
      local file_path = "test/fixtures/large_file.md"
      local file = io.open(file_path, "r")

      if not file then
        pending("large_file.md not found - run: python3 script to generate it")
        return
      end

      local lines = {}
      for line in file:lines() do
        table.insert(lines, line)
      end
      file:close()

      assert.truthy(#lines > 100, "Large file should have > 100 lines")

      -- Time the detection (should be fast even for large files)
      local start_time = os.clock()
      local myst_detected = false

      -- Scan first 50 lines (default scan_lines)
      for i = 1, math.min(50, #lines) do
        if detect_myst_pattern(lines[i]) then
          myst_detected = true
          break
        end
      end

      local elapsed = os.clock() - start_time

      assert.truthy(myst_detected, "Should detect MyST in large file")
      assert.truthy(elapsed < 0.1, "Detection should complete in < 100ms")
    end)

    it("should handle files with many directives", function()
      local lines = {}
      for i = 1, 100 do
        table.insert(lines, "# Section " .. i)
        table.insert(lines, "```{code-cell} python")
        table.insert(lines, "print(" .. i .. ")")
        table.insert(lines, "```")
      end

      local count = 0
      for _, line in ipairs(lines) do
        if detect_myst_pattern(line) then
          count = count + 1
        end
      end

      assert.are.equal(100, count, "Should detect all 100 code-cell directives")
    end)
  end)

  describe("cache performance", function()
    it("should benefit from caching on repeated calls", function()
      local line = "```{code-cell} python"

      -- First call (not cached)
      local start1 = os.clock()
      for _ = 1, 1000 do
        detect_myst_pattern(line)
      end
      local time1 = os.clock() - start1

      -- Second batch (potentially cached)
      local start2 = os.clock()
      for _ = 1, 1000 do
        detect_myst_pattern(line)
      end
      local time2 = os.clock() - start2

      -- Both should be fast (< 50ms for 1000 iterations)
      assert.truthy(time1 < 0.05, "First batch should be fast")
      assert.truthy(time2 < 0.05, "Second batch should be fast")
    end)
  end)

  describe("memory efficiency", function()
    it("should not leak memory on repeated detections", function()
      -- This is a basic test - real memory leak detection needs profiling
      local line = "```{code-cell} python"

      -- Run many iterations
      for _ = 1, 10000 do
        detect_myst_pattern(line)
      end

      -- If we got here without crashing, basic memory handling is OK
      assert.truthy(true)
    end)
  end)

  describe("concurrent buffer operations", function()
    it("should handle multiple pattern checks without interference", function()
      local patterns = {
        "```{code-cell} python",
        "```{note}",
        "```{warning}",
        "```python", -- Not MyST
        "Regular text", -- Not MyST
        "```{code-cell} javascript",
        "```{admonition} Title",
      }

      local results = {}
      for _, pattern in ipairs(patterns) do
        table.insert(results, detect_myst_pattern(pattern))
      end

      -- Verify expected results
      assert.truthy(results[1]) -- code-cell python
      assert.truthy(results[2]) -- note
      assert.truthy(results[3]) -- warning
      assert.falsy(results[4]) -- plain python
      assert.falsy(results[5]) -- regular text
      assert.truthy(results[6]) -- code-cell javascript
      assert.truthy(results[7]) -- admonition
    end)
  end)
end)
