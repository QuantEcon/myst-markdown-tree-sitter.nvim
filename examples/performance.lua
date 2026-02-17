-- Performance-Optimized MyST Markdown Configuration
-- Recommended for large files or slower systems

require('myst-markdown').setup({
  detection = {
    -- Scan fewer lines for better performance
    -- Only the first 25 lines will be checked for MyST patterns
    scan_lines = 25,
  },

  performance = {
    -- Keep caching enabled (critical for performance)
    cache_enabled = true,
  },

  highlighting = {
    enabled = true,
  },
})

-- Optional: Lazy load the plugin only for markdown files
-- This is configured in your plugin manager, not here
-- See examples/lazy-nvim.lua for details

-- Performance tip: Ensure tree-sitter parsers are compiled
-- Run: :TSInstall! markdown markdown_inline python javascript
