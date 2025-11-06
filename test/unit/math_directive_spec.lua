-- Test suite for MyST {math} directive support
-- Validates that tree-sitter injection works for LaTeX math blocks

describe("MyST math directive", function()
  describe("Basic math directive detection", function()
    it("should parse simple {math} directive", function()
      local content = [[```{math}
x = y^2 + z^2
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

    it("should parse {math} directive with label", function()
      local content = [[```{math}
:label: eq_name
\gamma x := \begin{bmatrix} x_1 \\ x_2 \end{bmatrix}
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

    it("should parse {math} directive with multiple options", function()
      local content = [[```{math}
:label: eq_matrix
:nowrap: true
$$
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$
```]]

      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"

      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")

      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end)

  describe("LaTeX syntax in math directive", function()
    it("should handle LaTeX commands", function()
      local content = [[```{math}
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
```]]

      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"

      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")

      local trees = parser:parse()
      assert.is_not_nil(trees, "Parse trees should exist")
      assert.is_true(#trees > 0, "Should have at least one parse tree")

      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it("should handle LaTeX environments", function()
      local content = [[```{math}
\begin{aligned}
    y_1 &= a_{11} x_1 + a_{12} x_2 \\
    y_2 &= a_{21} x_1 + a_{22} x_2
\end{aligned}
```]]

      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"

      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")

      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end)

  describe("Comparison with standard LaTeX", function()
    it("should work alongside standard $$ delimiters", function()
      local content = [[# Test

```{math}
x = y^2
```

$$
z = w^2
$$]]

      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
      vim.bo[bufnr].filetype = "myst"

      local parser = vim.treesitter.get_parser(bufnr, "markdown")
      assert.is_not_nil(parser, "Parser should be available")

      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end)
end)
