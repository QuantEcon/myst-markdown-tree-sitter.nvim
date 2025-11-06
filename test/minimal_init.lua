-- Minimal init.lua for testing
-- This provides a clean Neovim environment for running tests

-- Add plugin to runtimepath
vim.opt.rtp:append(".")

-- Add plenary to runtimepath (lazy.nvim installation)
vim.opt.rtp:append(vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim"))

-- Add nvim-treesitter to runtimepath (lazy.nvim installation)
vim.opt.rtp:append(vim.fn.expand("~/.local/share/nvim/lazy/nvim-treesitter"))

-- Ensure tree-sitter parsers are available
vim.opt.runtimepath:append(vim.fn.expand("~/.local/share/nvim/lazy/nvim-treesitter"))

-- Set up tree-sitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "markdown", "markdown_inline", "python", "lua" },
  highlight = { enable = true },
})

-- Load the plugin
require("myst-markdown").setup()

-- Disable swap files and other distractions
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Set up path for test fixtures
vim.g.myst_test_dir = vim.fn.getcwd() .. "/test"
