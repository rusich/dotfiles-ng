-- [[ Setting options ]]
-- See `:help opt`

local opt = vim.opt

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Make line numbers default
opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
opt.clipboard = 'unnamedplus'

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = 'yes'

-- Decrease update time
opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
opt.inccommand = 'split'

-- Show which line your cursor is on
opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 5

opt.cmdheight = 1 -- 0 is not working with org change todo state

-- Only one statuline on bottom of screen
opt.laststatus = 3

opt.wrap = false

-- Folding
-- opt.foldmethod = 'indent'
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- vim.opt.foldmethod = 'marker'
-- opt.foldtext = ''
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Set colorscheme
-- pcall(vim.cmd.colorscheme, 'catppuccin')
-- pcall(vim.cmd.colorscheme, 'onedark')
-- pcall(vim.cmd.colorscheme, 'kanagawa')
-- pcall(vim.cmd.colorscheme, 'carbonfox')
-- pcall(vim.cmd.colorscheme, 'oxocarbon')

-- Spell
opt.spelllang = 'ru,en'

opt.winborder = 'rounded'
opt.winblend = 5

opt.icm = 'split'

-- Global Float transparency
-- opt.winblend = require('core.config').ui.winblend

-- Vimscript Plugins global configuration
--
--
