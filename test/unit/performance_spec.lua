-- Performance tests for MyST detection
-- Tests detection performance on real buffers using the actual module code.

describe("performance tests", function()
  local filetype = require("myst-markdown.filetype")
  local config = require("myst-markdown.config")

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

  describe("large buffer handling", function()
    it("should detect MyST in a large buffer quickly", function()
      -- Build a buffer with 500 lines, MyST on line 3
      local lines = { "# Large file", "", "```{code-cell} python" }
      for i = 4, 500 do
        lines[i] = "Line " .. i
      end

      local buf = make_buf(lines)

      local start_time = os.clock()
      local detected = filetype.detect_myst(buf)
      local elapsed = os.clock() - start_time

      assert.is_true(detected)
      assert.is_true(elapsed < 0.1, "Detection should complete in < 100ms")
    end)

    it("should handle buffer with many directives", function()
      local lines = {}
      for i = 1, 100 do
        table.insert(lines, "# Section " .. i)
        table.insert(lines, "```{code-cell} python")
        table.insert(lines, "print(" .. i .. ")")
        table.insert(lines, "```")
      end

      local buf = make_buf(lines)
      assert.is_true(filetype.detect_myst(buf))
    end)
  end)

  describe("cache performance", function()
    it("should return cached result on second call", function()
      config.merge({ performance = { cache_enabled = true } })
      local buf = make_buf({ "```{code-cell} python", "x = 1", "```" })

      -- First call: populates cache
      local t1 = os.clock()
      assert.is_true(filetype.detect_myst(buf))
      local first = os.clock() - t1

      -- Second call: should use cache (and be at least as fast)
      local t2 = os.clock()
      assert.is_true(filetype.detect_myst(buf))
      local second = os.clock() - t2

      -- Both should be very fast
      assert.is_true(first < 0.05, "First call should be < 50ms")
      assert.is_true(second < 0.05, "Cached call should be < 50ms")
    end)

    it("should invalidate cache with clear_cache", function()
      config.merge({ performance = { cache_enabled = true } })
      local buf = make_buf({ "```{code-cell} python" })

      assert.is_true(filetype.detect_myst(buf))

      -- Replace content, clear cache, re-detect
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "plain text" })
      filetype.clear_cache(buf)
      assert.is_false(filetype.detect_myst(buf))
    end)

    it("should invalidate all caches with clear_all_caches", function()
      config.merge({ performance = { cache_enabled = true } })
      local buf1 = make_buf({ "```{code-cell} python" })
      local buf2 = make_buf({ "```{note}" })

      assert.is_true(filetype.detect_myst(buf1))
      assert.is_true(filetype.detect_myst(buf2))

      -- Replace both, clear all caches
      vim.api.nvim_buf_set_lines(buf1, 0, -1, false, { "plain" })
      vim.api.nvim_buf_set_lines(buf2, 0, -1, false, { "plain" })
      filetype.clear_all_caches()

      assert.is_false(filetype.detect_myst(buf1))
      assert.is_false(filetype.detect_myst(buf2))
    end)
  end)

  describe("scan_lines configuration", function()
    it("should scan only the configured number of lines", function()
      local lines = {}
      for i = 1, 100 do
        lines[i] = "Plain line " .. i
      end
      lines[10] = "```{code-cell} python"

      local buf = make_buf(lines)

      -- Default scan_lines = 50, so line 10 is within range
      assert.is_true(filetype.detect_myst(buf))

      -- Set scan_lines = 5, so line 10 is out of range
      config.merge({ detection = { scan_lines = 5 } })
      filetype.clear_all_caches()
      assert.is_false(filetype.detect_myst(buf))
    end)
  end)
end)
