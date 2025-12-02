-- Filetype detection for MyST markdown files
-- This file is loaded automatically by Neovim before plugins.
-- We use vim.filetype.add() for early detection, then the main plugin
-- setup() adds additional autocmds with caching support.

vim.filetype.add({
  extension = {
    md = function(path, bufnr)
      -- Check first 50 lines for MyST patterns
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 50, false)
      for _, line in ipairs(lines) do
        if
          line:match("^```{code%-cell}")
          or line:match("^```{[%w%-_]+}")
          or line:match("^{[%w%-_]+}")
        then
          return "myst"
        end
      end
      return "markdown"
    end,
  },
})
