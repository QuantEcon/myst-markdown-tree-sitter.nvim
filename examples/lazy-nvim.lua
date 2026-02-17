-- Complete lazy.nvim Plugin Specification
-- Copy this to your lazy.nvim plugin configuration

return {
  'QuantEcon/myst-markdown-tree-sitter.nvim',
  
  -- Dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  
  -- Load after startup so injection queries are in runtimepath before any
  -- markdown file opens.  Avoid ft = {"markdown","myst"} because that can
  -- cause the plugin to load after nvim-treesitter has already cached
  -- markdown queries, which may prevent {code-cell} highlighting.
  event = "VeryLazy",
  
  -- Plugin configuration
  config = function()
    require('myst-markdown').setup({
      detection = {
        scan_lines = 50,
      },
      performance = {
        cache_enabled = true,
      },
      highlighting = {
        enabled = true,
      },
    })
    
    -- Optional: Add keymaps
    vim.keymap.set('n', '<leader>mi', ':MystInfo<CR>', 
      { desc = 'MyST: Show info', silent = true })
    vim.keymap.set('n', '<leader>ms', ':MystStatus<CR>', 
      { desc = 'MyST: Check status', silent = true })
    vim.keymap.set('n', '<leader>md', ':MystDebug<CR>', 
      { desc = 'MyST: Debug info', silent = true })
  end,
  
  -- Optional: Install specific git branch for testing
  -- branch = 'develop',
  
  -- Optional: Pin to specific commit
  -- commit = 'abc123',
  
  -- Optional: Install from specific tag
  -- tag = 'v1.0.0',
}

-- If you prefer inline plugin specs, add this to your lazy.nvim setup:
--
-- require('lazy').setup({
--   -- ... other plugins ...
--   {
--     'QuantEcon/myst-markdown-tree-sitter.nvim',
--     dependencies = { 'nvim-treesitter/nvim-treesitter' },
--     event = "VeryLazy",
--     config = function()
--       require('myst-markdown').setup()
--     end,
--   },
--   -- ... other plugins ...
-- })
