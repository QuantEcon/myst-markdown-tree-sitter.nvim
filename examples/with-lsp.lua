-- Integration with LSP and Other Development Tools
-- Configuration for working with LSP servers, linters, and formatters

require('myst-markdown').setup({
  detection = {
    scan_lines = 50,
  },
  performance = {
    defer_timeout = 50,
    refresh_wait = 100,
    cache_enabled = true,
  },
  highlighting = {
    enabled = true,
  },
})

-- Optional: Configure marksman LSP for MyST markdown
-- Marksman provides completion, diagnostics, and navigation
-- Install: brew install marksman (macOS) or see https://github.com/artempyanykh/marksman

-- Example with nvim-lspconfig:
-- local lspconfig = require('lspconfig')
-- lspconfig.marksman.setup({
--   filetypes = { "markdown", "myst" },
--   root_dir = lspconfig.util.root_pattern(".git", ".marksman.toml"),
-- })

-- Optional: Configure markdown linters with null-ls / none-ls
-- Example with none-ls (null-ls successor):
-- local null_ls = require("null-ls")
-- null_ls.setup({
--   sources = {
--     -- Markdown linter
--     null_ls.builtins.diagnostics.markdownlint.with({
--       filetypes = { "markdown", "myst" },
--     }),
--     -- Markdown formatter
--     null_ls.builtins.formatting.prettier.with({
--       filetypes = { "markdown", "myst" },
--     }),
--   },
-- })

-- Optional: Configure conform.nvim for formatting
-- local conform = require("conform")
-- conform.setup({
--   formatters_by_ft = {
--     markdown = { "prettier" },
--     myst = { "prettier" },
--   },
-- })

-- Optional: Configure nvim-lint for linting
-- require('lint').linters_by_ft = {
--   markdown = { 'markdownlint' },
--   myst = { 'markdownlint' },
-- }

-- Optional: Integrate with render-markdown.nvim for preview
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
-- require('render-markdown').setup({
--   file_types = { 'markdown', 'myst' },
-- })

-- Optional: Markdown preview integration
-- With markdown-preview.nvim:
-- vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>', 
--   { desc = 'Markdown: Preview' })

-- Optional: Integrate with vim-markdown for additional features
-- Note: Ensure myst-markdown loads AFTER vim-markdown (priority setting)
