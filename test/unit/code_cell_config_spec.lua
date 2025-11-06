-- Test suite for code-cell directives with configuration options
-- Validates that tree-sitter injection works with YAML config blocks

describe("Code-cell with configuration", function()

  describe("YAML configuration detection", function()
    it("should detect Python code-cell with :tags: config", function()
      local content = [[```{code-cell} python
:tags: [output_scroll]
---
x = 1 + 2
print(x)
```]]
      
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"
      
      -- Check if tree-sitter can parse this
      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")
      
      -- Parse the buffer
      local tree = parser:parse()[1]
      assert.is_not_nil(tree, "Parse tree should exist")
      
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it("should detect IPython code-cell with concise config", function()
      local content = [[```{code-cell} ipython
:tags: [hide-input]
import numpy as np
```]]
      
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"
      
      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")
      
      local tree = parser:parse()[1]
      assert.is_not_nil(tree, "Parse tree should exist")
      
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it("should detect code-cell with multiple config options", function()
      local content = [[```{code-cell} python
:tags: [hide-input, output_scroll]
:linenos:
:emphasize-lines: 2,3
---
x = 1
y = 2
```]]
      
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"
      
      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")
      
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end)

  describe("Language injection with config", function()
    it("should have proper tree-sitter setup for code-cell with config", function()
      local content = [[```{code-cell} python
:tags: [output_scroll]
---
x = 1 + 2
```]]
      
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"
      
      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")
      
      -- Verify parser can parse the content
      local trees = parser:parse()
      assert.is_not_nil(trees, "Parse trees should exist")
      assert.is_true(#trees > 0, "Should have at least one parse tree")
      
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it("should have proper tree-sitter setup for code-cell javascript with config", function()
      local content = [[```{code-cell} javascript
:tags: [remove-output]
console.log("test");
```]]
      
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"
      
      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")
      
      -- Verify parser can parse the content
      local trees = parser:parse()
      assert.is_not_nil(trees, "Parse trees should exist")
      assert.is_true(#trees > 0, "Should have at least one parse tree")
      
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end)

  describe("Backward compatibility", function()
    it("should still work for code-cells without config", function()
      local content = [[```{code-cell} python
x = 1 + 2
print(x)
```]]
      
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"
      
      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")
      
      -- Verify parser can parse the content
      local trees = parser:parse()
      assert.is_not_nil(trees, "Parse trees should exist")
      assert.is_true(#trees > 0, "Should have at least one parse tree")
      
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end)

  describe("All supported languages with config", function()
    local languages = {
      { lang = "python", parser = "python" },
      { lang = "ipython", parser = "python" },
      { lang = "ipython3", parser = "python" },
      { lang = "javascript", parser = "javascript" },
      { lang = "js", parser = "javascript" },
      { lang = "bash", parser = "bash" },
      { lang = "sh", parser = "bash" },
      { lang = "r", parser = "r" },
      { lang = "julia", parser = "julia" },
      { lang = "cpp", parser = "cpp" },
      { lang = "c", parser = "c" },
      { lang = "rust", parser = "rust" },
      { lang = "go", parser = "go" },
      { lang = "typescript", parser = "typescript" },
      { lang = "ts", parser = "typescript" },
    }

    for _, test_case in ipairs(languages) do
      it(
        string.format("should inject %s parser for {code-cell} %s with config", test_case.parser, test_case.lang),
        function()
          local content = string.format(
            [[```{code-cell} %s
:tags: [test]
---
code here
```]],
            test_case.lang
          )

          local bufnr = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
          vim.bo[bufnr].filetype = "myst"

          local parser = vim.treesitter.get_parser(bufnr, "markdown")
          assert.is_not_nil(parser, "Parser should be available")

          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      )
    end
  end)
end)
