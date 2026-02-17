-- Minimal init.lua for testing
-- Provides a clean Neovim environment for running tests with plenary.nvim.
-- Works in both CI (packer-style paths) and local dev (lazy.nvim paths).

-- Add the plugin itself to runtimepath
vim.opt.rtp:prepend(".")

-- Try common installation locations for dependencies.
-- The first path that exists wins; duplicates in rtp are harmless.
local dependency_roots = {
  -- lazy.nvim (local dev)
  vim.fn.expand("~/.local/share/nvim/lazy"),
  -- packer start (CI)
  vim.fn.expand("~/.local/share/nvim/site/pack/packer/start"),
  -- packer opt
  vim.fn.expand("~/.local/share/nvim/site/pack/packer/opt"),
}

for _, root in ipairs(dependency_roots) do
  if vim.fn.isdirectory(root .. "/plenary.nvim") == 1 then
    vim.opt.rtp:append(root .. "/plenary.nvim")
  end
  if vim.fn.isdirectory(root .. "/nvim-treesitter") == 1 then
    vim.opt.rtp:append(root .. "/nvim-treesitter")
  end
end

-- Ensure tree-sitter parsers are available (best-effort in CI)
local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
if ts_ok then
  ts_configs.setup({
    ensure_installed = { "markdown", "markdown_inline", "python", "lua" },
    highlight = { enable = true },
  })
end

-- Initialise the plugin with default options
require("myst-markdown").setup()

-- Disable distracting Neovim features during tests
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Convenience global for fixture paths
vim.g.myst_test_dir = vim.fn.getcwd() .. "/test"
