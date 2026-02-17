-- Integration tests for plugin setup and configuration

describe("plugin setup", function()
  describe("module loading", function()
    it("should load all core modules without error", function()
      local modules = {
        "myst-markdown",
        "myst-markdown.config",
        "myst-markdown.utils",
        "myst-markdown.filetype",
        "myst-markdown.highlighting",
        "myst-markdown.commands",
        "myst-markdown.version",
      }

      for _, mod in ipairs(modules) do
        local ok, err = pcall(require, mod)
        assert.is_true(ok, "Failed to load " .. mod .. ": " .. tostring(err))
      end
    end)
  end)

  describe("setup status", function()
    it("should report setup as complete after minimal_init", function()
      local myst = require("myst-markdown")
      assert.is_true(myst.is_setup())
    end)
  end)

  describe("configuration", function()
    it("should have default configuration", function()
      local config = require("myst-markdown.config")
      assert.is_not_nil(config.defaults)
      assert.is_table(config.defaults)
    end)

    it("should have expected default values", function()
      local config = require("myst-markdown.config")
      local defaults = config.defaults

      assert.is_not_nil(defaults.detection)
      assert.is_not_nil(defaults.detection.scan_lines)
      assert.is_number(defaults.detection.scan_lines)
      assert.is_not_nil(defaults.highlighting)
      assert.is_not_nil(defaults.highlighting.enabled)
      assert.is_boolean(defaults.highlighting.enabled)
    end)

    it("should not expose unused language config", function()
      local config = require("myst-markdown.config")
      -- languages and language_aliases were removed as they were misleading
      assert.is_nil(config.defaults.languages)
      assert.is_nil(config.defaults.language_aliases)
    end)
  end)

  describe("utils module", function()
    it("should provide logging functions", function()
      local utils = require("myst-markdown.utils")
      assert.is_function(utils.debug)
      assert.is_function(utils.info)
      assert.is_function(utils.warn)
      assert.is_function(utils.error)
    end)

    it("should provide buffer validation", function()
      local utils = require("myst-markdown.utils")
      assert.is_function(utils.is_valid_buffer)
      assert.is_function(utils.resolve_buf)
    end)

    it("should provide tree-sitter helpers", function()
      local utils = require("myst-markdown.utils")
      assert.is_function(utils.has_treesitter)
      assert.is_function(utils.has_parser)
      assert.is_function(utils.ts_get_query)
    end)
  end)

  describe("filetype module", function()
    it("should provide detection function", function()
      local ft = require("myst-markdown.filetype")
      assert.is_function(ft.detect_myst)
    end)

    it("should provide cache clearing", function()
      local ft = require("myst-markdown.filetype")
      assert.is_function(ft.clear_cache)
      assert.is_function(ft.clear_all_caches)
    end)
  end)

  describe("highlighting module", function()
    it("should provide setup_filetype_autocmd", function()
      local hl = require("myst-markdown.highlighting")
      assert.is_function(hl.setup_filetype_autocmd)
    end)

    it("should provide setup_treesitter", function()
      local hl = require("myst-markdown.highlighting")
      assert.is_function(hl.setup_treesitter)
    end)

    it("should provide setup_highlight_groups", function()
      local hl = require("myst-markdown.highlighting")
      assert.is_function(hl.setup_highlight_groups)
    end)
  end)
end)
