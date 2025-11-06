-- Jupyter Notebook Integration Configuration
-- For working with MyST notebooks and Jupyter-style workflows

require('myst-markdown').setup({
  detection = {
    -- Scan more lines since Jupyter notebooks may have
    -- frontmatter or metadata at the top
    scan_lines = 100,
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

-- Recommended: Install additional parsers for common notebook languages
-- :TSInstall python javascript julia r

-- Optional: Integration with jupytext or molten.nvim
-- These plugins allow you to run code cells directly in Neovim

-- Example with molten.nvim for executing code cells:
-- https://github.com/benlubas/molten-nvim
--
-- vim.keymap.set('n', '<leader>mr', ':MoltenEvaluateOperator<CR>', 
--   { desc = 'Molten: Run cell' })

-- Example with jupytext for syncing with .ipynb files:
-- Use jupytext to pair .md and .ipynb files:
-- $ jupytext --set-formats ipynb,md notebook.ipynb

-- Common Jupyter cell metadata in MyST:
-- ```{code-cell} ipython
-- :tags: [hide-cell, remove-output]
-- 
-- import numpy as np
-- ```
