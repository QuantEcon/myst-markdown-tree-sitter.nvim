-- Advanced MyST Markdown Configuration
-- Full configuration showing all available options

require('myst-markdown').setup({
  -- Filetype detection settings
  detection = {
    -- Number of lines from the beginning of file to scan for MyST patterns
    -- Increase if MyST directives appear later in your files
    -- Decrease for faster detection on large files
    scan_lines = 50,  -- Default: 50
  },

  -- Performance tuning
  performance = {
    -- Enable caching of filetype detection results
    -- Prevents re-scanning files unnecessarily
    cache_enabled = true,  -- Default: true
  },

  -- Highlighting control
  highlighting = {
    -- Enable or disable MyST-specific highlighting
    -- Set to false to temporarily disable without uninstalling
    enabled = true,  -- Default: true
  },
})

-- Optional: Add custom keymaps for MyST commands
vim.keymap.set('n', '<leader>mi', ':MystInfo<CR>', { desc = 'MyST: Show info' })
vim.keymap.set('n', '<leader>ms', ':MystStatus<CR>', { desc = 'MyST: Check status' })
vim.keymap.set('n', '<leader>md', ':MystDebug<CR>', { desc = 'MyST: Debug info' })

-- Optional: Custom highlight groups (if you want to override colors)
vim.api.nvim_set_hl(0, 'MystDirective', { link = 'Special' })
vim.api.nvim_set_hl(0, 'MystCodeCell', { link = 'Function' })
