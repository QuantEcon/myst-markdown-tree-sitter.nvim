-- Test for filetype detection integration
-- Run with: nvim --headless -c "PlenaryBustedDirectory test/integration/ {minimal_init = 'test/minimal_init.lua'}"

describe("filetype detection", function()
  local fixtures_dir = vim.g.myst_test_dir .. "/fixtures"

  before_each(function()
    -- Clear any existing buffers
    vim.cmd("bufdo bwipeout!")
  end)

  after_each(function()
    -- Clean up
    vim.cmd("bufdo bwipeout!")
  end)

  describe("basic MyST file", function()
    it("should detect basic_myst.md as myst filetype", function()
      local filepath = fixtures_dir .. "/basic_myst.md"
      vim.cmd("edit " .. filepath)

      -- Wait for filetype detection to complete
      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      assert.equals("myst", vim.bo.filetype)
    end)
  end)

  describe("edge cases file", function()
    it("should detect edge_cases.md as myst filetype", function()
      local filepath = fixtures_dir .. "/edge_cases.md"
      vim.cmd("edit " .. filepath)

      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      assert.equals("myst", vim.bo.filetype)
    end)
  end)

  describe("regular markdown file", function()
    it("should detect regular_markdown.md as markdown filetype", function()
      local filepath = fixtures_dir .. "/regular_markdown.md"
      vim.cmd("edit " .. filepath)

      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      -- Should stay as markdown since there are no MyST directives
      assert.equals("markdown", vim.bo.filetype)
    end)
  end)

  describe("tree-sitter integration", function()
    it("should load markdown parser for myst files", function()
      local filepath = fixtures_dir .. "/basic_myst.md"
      vim.cmd("edit " .. filepath)
      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      -- Check if tree-sitter is available
      local has_ts = pcall(require, "nvim-treesitter.parsers")
      if has_ts then
        local parsers = require("nvim-treesitter.parsers")
        -- Check that myst filetype is mapped to markdown parser
        local parser_name = parsers.filetype_to_parsername.myst
        assert.equals("markdown", parser_name)
      end
    end)
  end)

  describe("buffer content", function()
    it("should load file content correctly", function()
      local filepath = fixtures_dir .. "/basic_myst.md"
      vim.cmd("edit " .. filepath)

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.is_true(#lines > 0)

      -- Check that we have the expected content
      local has_code_cell = false
      for _, line in ipairs(lines) do
        if line:match("```{code%-cell}") then
          has_code_cell = true
          break
        end
      end
      assert.is_true(has_code_cell)
    end)
  end)
end)
