-- Integration tests for version management
-- Run with: nvim --headless -c "PlenaryBustedDirectory test/integration/ {minimal_init = 'test/minimal_init.lua'}"

describe("version management", function()
  describe("single source of truth", function()
    it("should have version defined in version.lua", function()
      local version = require("myst-markdown.version")
      assert.is_not_nil(version)
      assert.is_string(version)
      assert.is_true(version:match("^%d+%.%d+%.%d+$") ~= nil, "Version should match semver format")
    end)

    it("should expose same version via init module", function()
      local init = require("myst-markdown")
      local version = require("myst-markdown.version")
      assert.equals(version, init.version)
    end)

    it("should have consistent version across all access points", function()
      local version_module = require("myst-markdown.version")
      local init = require("myst-markdown")

      -- All should be the same
      assert.equals(version_module, init.version)
    end)
  end)

  describe("version format", function()
    it("should follow semantic versioning", function()
      local version = require("myst-markdown.version")

      -- Extract major.minor.patch
      local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)$")

      assert.is_not_nil(major, "Should have major version")
      assert.is_not_nil(minor, "Should have minor version")
      assert.is_not_nil(patch, "Should have patch version")

      -- Convert to numbers
      major = tonumber(major)
      minor = tonumber(minor)
      patch = tonumber(patch)

      assert.is_true(major >= 0, "Major version should be non-negative")
      assert.is_true(minor >= 0, "Minor version should be non-negative")
      assert.is_true(patch >= 0, "Patch version should be non-negative")
    end)
  end)
end)
