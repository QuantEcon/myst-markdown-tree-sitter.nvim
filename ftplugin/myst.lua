-- MyST filetype settings
-- This file is loaded when filetype is set to 'myst'

-- Inherit from markdown settings
vim.cmd("runtime! ftplugin/markdown.vim")

-- MyST-specific settings
vim.bo.commentstring = "<!-- %s -->"
vim.bo.comments = "b:<!--,e:-->"
