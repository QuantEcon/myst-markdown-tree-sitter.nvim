-- Luacheck configuration for myst-markdown-tree-sitter.nvim
-- https://luacheck.readthedocs.io/en/stable/

-- Use std = "luajit" for LuaJIT compatibility (Neovim uses LuaJIT)
std = "luajit"

-- Extend standard library with Neovim globals
globals = {
  "vim",  -- Main vim global
}

-- Read-only globals (don't warn about not setting these)
read_globals = {
  "vim",
}

-- Ignore specific warnings
ignore = {
  "211",  -- Unused local variable (sometimes unavoidable in callbacks)
  "212",  -- Unused argument (common in vim callbacks)
  "213",  -- Unused loop variable
}

-- Don't report unused self arguments
self = false

-- Files and directories to exclude
exclude_files = {
  -- Exclude external dependencies if vendored
  ".luarocks/",
  "lua_modules/",
  -- Exclude test scaffolding if needed
  -- "test/minimal_init.lua",
}

-- Maximum line length
max_line_length = 100

-- Maximum code complexity (cyclomatic complexity)
max_code_line_length = 100
max_comment_line_length = 100
max_cyclomatic_complexity = 15

-- Neovim-specific configuration
-- Allow Neovim API naming conventions
files["lua/**/*.lua"] = {
  ignore = {
    "631",  -- Line is too long (for long vim.notify messages)
  },
}

-- Test files may have different standards
files["test/**/*.lua"] = {
  ignore = {
    "113",  -- Accessing undefined variable (plenary provides test globals)
    "212",  -- Unused argument (test functions may not use all parameters)
  },
  globals = {
    "describe",      -- Plenary test function
    "it",           -- Plenary test function
    "before_each",  -- Plenary test function
    "after_each",   -- Plenary test function
    "assert",       -- Plenary assertion library
    "pending",      -- Plenary pending test marker
  },
}

-- Allow vim globals in plugin files
files["plugin/**/*.lua"] = {
  globals = {
    "vim",
  },
}

-- Allow vim globals in ftdetect files
files["ftdetect/**/*.lua"] = {
  globals = {
    "vim",
  },
}

-- Allow vim globals in ftplugin files
files["ftplugin/**/*.lua"] = {
  globals = {
    "vim",
  },
}
