-- Integration tests for user commands
-- Run with: nvim --headless -c "PlenaryBustedDirectory test/integration/ {minimal_init = 'test/minimal_init.lua'}"

describe("user commands", function()
  local fixtures_dir = vim.g.myst_test_dir .. "/fixtures"

  before_each(function()
    vim.cmd("bufdo bwipeout!")
  end)

  after_each(function()
    vim.cmd("bufdo bwipeout!")
  end)

  describe(":MystInfo", function()
    it("should be available after setup", function()
      -- Command should exist
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.MystInfo)
    end)

    it("should execute without error", function()
      local success = pcall(function()
        vim.cmd("MystInfo")
      end)
      assert.is_true(success)
    end)
  end)

  describe(":MystStatus", function()
    it("should be available after setup", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.MystStatus)
    end)

    it("should execute without error on MyST file", function()
      local filepath = fixtures_dir .. "/basic_myst.md"
      vim.cmd("edit " .. filepath)
      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      local success = pcall(function()
        vim.cmd("MystStatus")
      end)
      assert.is_true(success)
    end)

    it("should execute without error on regular markdown", function()
      local filepath = fixtures_dir .. "/regular_markdown.md"
      vim.cmd("edit " .. filepath)
      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      local success = pcall(function()
        vim.cmd("MystStatus")
      end)
      assert.is_true(success)
    end)
  end)

  describe(":MystDebug", function()
    it("should be available after setup", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.MystDebug)
    end)

    it("should execute without error", function()
      local filepath = fixtures_dir .. "/basic_myst.md"
      vim.cmd("edit " .. filepath)
      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      local success = pcall(function()
        vim.cmd("MystDebug")
      end)
      assert.is_true(success)
    end)
  end)
end)
