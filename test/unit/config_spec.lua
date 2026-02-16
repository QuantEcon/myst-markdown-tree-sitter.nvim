-- Unit tests for the config module
-- Tests merge, get, get_value, and validate.

describe("config module", function()
  local config = require("myst-markdown.config")

  before_each(function()
    -- Reset to defaults before every test
    config.merge({})
  end)

  -- ----------------------------------------------------------------
  -- Defaults
  -- ----------------------------------------------------------------
  describe("defaults", function()
    it("should expose a defaults table", function()
      assert.is_table(config.defaults)
    end)

    it("should have expected default values", function()
      local d = config.defaults
      assert.is_false(d.debug)
      assert.is_number(d.detection.scan_lines)
      assert.are.equal(50, d.detection.scan_lines)
      assert.is_true(d.performance.cache_enabled)
      assert.is_true(d.highlighting.enabled)
    end)
  end)

  -- ----------------------------------------------------------------
  -- merge
  -- ----------------------------------------------------------------
  describe("merge", function()
    it("should return defaults when called with nil", function()
      local cfg = config.merge(nil)
      assert.are.equal(50, cfg.detection.scan_lines)
    end)

    it("should override a single value", function()
      config.merge({ detection = { scan_lines = 100 } })
      assert.are.equal(100, config.get().detection.scan_lines)
    end)

    it("should preserve unset defaults", function()
      config.merge({ debug = true })
      assert.is_true(config.get().debug)
      assert.are.equal(50, config.get().detection.scan_lines)
    end)
  end)

  -- ----------------------------------------------------------------
  -- get / get_value
  -- ----------------------------------------------------------------
  describe("get", function()
    it("should return the current config table", function()
      config.merge({ debug = true })
      local cfg = config.get()
      assert.is_true(cfg.debug)
    end)

    it("should return defaults before setup is called", function()
      -- Simulate un-initialised state
      config.config = {}
      local cfg = config.get()
      assert.is_table(cfg)
      assert.is_number(cfg.detection.scan_lines)
    end)
  end)

  describe("get_value", function()
    it("should retrieve a nested value by dot path", function()
      config.merge({})
      assert.are.equal(50, config.get_value("detection.scan_lines"))
    end)

    it("should return nil for non-existent path", function()
      config.merge({})
      assert.is_nil(config.get_value("does.not.exist"))
    end)

    it("should retrieve a top-level boolean", function()
      config.merge({ debug = true })
      assert.is_true(config.get_value("debug"))
    end)
  end)

  -- ----------------------------------------------------------------
  -- validate
  -- ----------------------------------------------------------------
  describe("validate", function()
    it("should accept an empty table", function()
      local ok, err = config.validate({})
      assert.is_true(ok)
      assert.is_nil(err)
    end)

    it("should reject non-table input", function()
      local ok, err = config.validate("bad")
      assert.is_false(ok)
      assert.is_not_nil(err)
    end)

    it("should reject non-boolean debug", function()
      local ok, err = config.validate({ debug = "yes" })
      assert.is_false(ok)
      assert.truthy(err:match("debug"))
    end)

    it("should reject non-positive scan_lines", function()
      local ok, err = config.validate({ detection = { scan_lines = 0 } })
      assert.is_false(ok)
      assert.truthy(err:match("scan_lines"))
    end)

    it("should reject non-integer scan_lines", function()
      local ok, err = config.validate({ detection = { scan_lines = 3.5 } })
      assert.is_false(ok)
      assert.truthy(err:match("scan_lines"))
    end)

    it("should reject non-boolean cache_enabled", function()
      local ok, err = config.validate({ performance = { cache_enabled = 1 } })
      assert.is_false(ok)
      assert.truthy(err:match("cache_enabled"))
    end)

    it("should reject non-boolean highlighting.enabled", function()
      local ok, err = config.validate({ highlighting = { enabled = "true" } })
      assert.is_false(ok)
      assert.truthy(err:match("enabled"))
    end)

    it("should reject non-table detection.patterns", function()
      local ok, err = config.validate({ detection = { patterns = "bad" } })
      assert.is_false(ok)
      assert.truthy(err:match("patterns"))
    end)

    it("should reject non-string pattern values", function()
      local ok, err = config.validate({ detection = { patterns = { code_cell = 42 } } })
      assert.is_false(ok)
      assert.truthy(err:match("patterns"))
    end)

    it("should accept valid full configuration", function()
      local ok, err = config.validate({
        debug = true,
        detection = {
          scan_lines = 100,
          patterns = { code_cell = "^```{code%-cell}" },
        },
        performance = { cache_enabled = false },
        highlighting = { enabled = true },
      })
      assert.is_true(ok)
      assert.is_nil(err)
    end)
  end)
end)
