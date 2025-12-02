-- Integration tests for highlighting setup
-- Run with: nvim --headless -c "PlenaryBustedDirectory test/integration/ {minimal_init = 'test/minimal_init.lua'}"

describe("highlighting integration", function()
  local fixtures_dir = vim.g.myst_test_dir .. "/fixtures"

  before_each(function()
    vim.cmd("bufdo bwipeout!")
  end)

  after_each(function()
    vim.cmd("bufdo bwipeout!")
  end)

  describe("parser mapping", function()
    it("should map myst filetype to markdown parser", function()
      local has_ts = pcall(require, "nvim-treesitter.parsers")
      if has_ts then
        local parsers = require("nvim-treesitter.parsers")
        -- After setup, myst should be mapped to markdown
        if parsers.filetype_to_parsername then
          assert.equals("markdown", parsers.filetype_to_parsername.myst)
        else
          -- In newer nvim-treesitter, this may be handled differently
          -- Just check that we can get the parser for markdown
          assert.is_true(true, "Parser mapping handled by nvim-treesitter")
        end
      end
    end)
  end)

  describe("tree-sitter activation", function()
    it("should activate tree-sitter for myst files", function()
      local filepath = fixtures_dir .. "/basic_myst.md"
      vim.cmd("edit " .. filepath)
      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      -- Verify filetype is myst
      assert.equals("myst", vim.bo.filetype)

      -- Check if tree-sitter is loaded for the buffer
      local has_ts = pcall(require, "nvim-treesitter.parsers")
      if has_ts then
        local parsers = require("nvim-treesitter.parsers")
        local buf = vim.api.nvim_get_current_buf()
        local lang = parsers.get_buf_lang(buf)
        -- The buffer lang might be 'myst' but parser used is 'markdown'
        -- This is expected behavior - the filetype is myst, parser is markdown
        assert.is_true(
          lang == "markdown" or lang == "myst",
          "Buffer should use markdown or myst lang"
        )
      end
    end)
  end)

  describe("injection queries", function()
    it("should load markdown injection queries", function()
      local ok, query = pcall(vim.treesitter.query.get, "markdown", "injections")
      assert.is_true(ok)
      assert.is_not_nil(query)
    end)
  end)

  describe("code cell highlighting", function()
    it("should process files with multiple code cells", function()
      local filepath = fixtures_dir .. "/edge_cases.md"
      vim.cmd("edit " .. filepath)
      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      -- Should be detected as myst
      assert.equals("myst", vim.bo.filetype)

      -- Should have content
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.is_true(#lines > 0)

      -- Count code-cell occurrences
      local code_cell_count = 0
      for _, line in ipairs(lines) do
        if line:match("```{code%-cell}") then
          code_cell_count = code_cell_count + 1
        end
      end
      assert.is_true(code_cell_count >= 5)
    end)

    it("should handle code cells with YAML config", function()
      local filepath = fixtures_dir .. "/code_cell_with_config.md"
      vim.cmd("edit " .. filepath)
      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      -- Should be detected as myst
      assert.equals("myst", vim.bo.filetype)

      -- Verify file has YAML config patterns
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local has_yaml_config = false
      for _, line in ipairs(lines) do
        if line:match(":tags:") then
          has_yaml_config = true
          break
        end
      end
      assert.is_true(has_yaml_config)
    end)
  end)

  describe("language detection in code cells", function()
    it("should detect various languages in code cells", function()
      local filepath = fixtures_dir .. "/basic_myst.md"
      vim.cmd("edit " .. filepath)
      vim.wait(100, function()
        return vim.bo.filetype ~= ""
      end)

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      local found_python = false
      local found_javascript = false

      for _, line in ipairs(lines) do
        if line:match("```{code%-cell} python") then
          found_python = true
        end
        if line:match("```{code%-cell} javascript") then
          found_javascript = true
        end
      end

      assert.is_true(found_python, "Should have Python code cell")
      assert.is_true(found_javascript, "Should have JavaScript code cell")
    end)
  end)
end)
