-- Unit tests for the utils module

describe("utils module", function()
  local utils = require("myst-markdown.utils")

  -- ----------------------------------------------------------------
  -- resolve_buf
  -- ----------------------------------------------------------------
  describe("resolve_buf", function()
    it("should convert 0 to the current buffer number", function()
      local current = vim.api.nvim_get_current_buf()
      assert.are.equal(current, utils.resolve_buf(0))
    end)

    it("should pass through non-zero buffer numbers", function()
      assert.are.equal(42, utils.resolve_buf(42))
    end)
  end)

  -- ----------------------------------------------------------------
  -- is_valid_buffer
  -- ----------------------------------------------------------------
  describe("is_valid_buffer", function()
    it("should return true for the current buffer", function()
      assert.is_true(utils.is_valid_buffer(0))
    end)

    it("should return true for a real scratch buffer", function()
      local buf = vim.api.nvim_create_buf(false, true)
      assert.is_true(utils.is_valid_buffer(buf))
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("should return false for nil", function()
      assert.is_false(utils.is_valid_buffer(nil))
    end)

    it("should return false for a deleted buffer", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_delete(buf, { force = true })
      assert.is_false(utils.is_valid_buffer(buf))
    end)
  end)

  -- ----------------------------------------------------------------
  -- get_buf_lines
  -- ----------------------------------------------------------------
  describe("get_buf_lines", function()
    it("should return lines from a buffer", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "line1", "line2", "line3" })
      local lines = utils.get_buf_lines(buf, 0, 2)
      assert.are.same({ "line1", "line2" }, lines)
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("should return nil for an invalid buffer", function()
      assert.is_nil(utils.get_buf_lines(99999, 0, -1))
    end)
  end)

  -- ----------------------------------------------------------------
  -- matches_any
  -- ----------------------------------------------------------------
  describe("matches_any", function()
    it("should return true and the matched pattern", function()
      local ok, matched = utils.matches_any("hello world", { "xyz", "hello" })
      assert.is_true(ok)
      assert.are.equal("hello", matched)
    end)

    it("should return false and nil when no pattern matches", function()
      local ok, matched = utils.matches_any("hello", { "xyz", "abc" })
      assert.is_false(ok)
      assert.is_nil(matched)
    end)

    it("should return false for empty patterns list", function()
      local ok = utils.matches_any("hello", {})
      assert.is_false(ok)
    end)
  end)

  -- ----------------------------------------------------------------
  -- check_version
  -- ----------------------------------------------------------------
  describe("check_version", function()
    it("should pass for version 0.8.0 (minimum)", function()
      assert.is_true(utils.check_version(0, 8, 0))
    end)

    it("should pass for version 0.1.0 (very old)", function()
      assert.is_true(utils.check_version(0, 1, 0))
    end)
  end)

  -- ----------------------------------------------------------------
  -- ts_get_query
  -- ----------------------------------------------------------------
  describe("ts_get_query", function()
    it("should return nil for a non-existent language", function()
      local q = utils.ts_get_query("nonexistent_lang_xyz", "highlights")
      assert.is_nil(q)
    end)

    -- If markdown parser is installed, injections query should exist
    it("should return a query for markdown injections if parser available", function()
      local q = utils.ts_get_query("markdown", "injections")
      -- May be nil in CI without parsers, so just check it doesn't error
      if q then
        assert.is_not_nil(q)
      end
    end)
  end)

  -- ----------------------------------------------------------------
  -- Logging functions (smoke test — just ensure they don't error)
  -- ----------------------------------------------------------------
  describe("logging", function()
    it("should not error on info()", function()
      assert.has_no.errors(function()
        utils.info("test message")
      end)
    end)

    it("should not error on warn()", function()
      assert.has_no.errors(function()
        utils.warn("test warning")
      end)
    end)

    it("should not error on error()", function()
      assert.has_no.errors(function()
        utils.error("test error")
      end)
    end)

    it("should not error on debug() when disabled", function()
      utils._debug_enabled = false
      assert.has_no.errors(function()
        utils.debug("test debug")
      end)
    end)

    it("should not error on debug() when enabled", function()
      utils._debug_enabled = true
      assert.has_no.errors(function()
        utils.debug("test debug enabled")
      end)
      utils._debug_enabled = false
    end)
  end)
end)
