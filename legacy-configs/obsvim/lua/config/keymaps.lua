-- [[ Basic Keymaps ]]
--  See `:help set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
local map = vim.keymap.set
vim.opt.hlsearch = true
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
-- map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
map('n', '?', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
-- REPLACED WIT `vim-kitty-navigator`

-- Resize window using <ctrl> arrow keys
map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- Move Lines
map('n', '<A-Up>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
map('i', '<A-Down>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
map('i', '<A-Up>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
map('v', '<A-Down>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
map('v', '<A-Up>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })
map('n', '<A-Down>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })

-- Comment with <c-/>
map('n', '<C-/>', 'gcc', { desc = 'Toggle comment', remap = true })
map('v', '<C-/>', 'gc', { desc = 'Toggle comment', remap = true })

-- Folding
map('n', '<M-space>', 'za', { desc = 'Toggle fold' })
map('v', '<M-space>', 'zf', { desc = 'Toggle fold' })

-- Buffer next/previous
map('n', 'L', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', 'H', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })

-- Close current window with Ctrl+C
map('n', '<C-c>', '<cmd>close<CR>', { desc = 'Close window' })

-- Splits
map('n', '|', '<cmd>vsplit<CR>', { desc = 'Split window vertically' })
map('n', '_', '<cmd>split<CR>', { desc = 'Split window horizontally' })

-- Copy current file full path with:line_number to system clipboard
map('n', '<leader>olc', function()
  local file_path = vim.fn.expand '%:p'
  -- Replace $HOME with ~
  file_path = string.gsub(file_path, os.getenv 'HOME', '~')
  vim.fn.setreg('+', file_path .. '::' .. vim.fn.line '.')
end, { desc = 'org copy file link with line number to system buffer', silent = true })

-- Insert mode better navigation
--
-- Change to end of line in insert mode
map('i', '<C-c>', '<cmd>normal! Da<CR><Right>', { desc = 'Change to end of line' })

-- Fix xdg-open error
map('n', 'gx', '<cmd>silent !xdg-open <cfile> &<cr>', { desc = 'Open URL' })
-- ~/Nextcloud/Pictures/Icons/avatar.jpg

-- Snacks.nvim
Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
Snacks.toggle.diagnostics():map '<leader>ud'
Snacks.toggle.line_number():map '<leader>ul'
-- Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = 'Conceal Level' }):map '<leader>uc'
Snacks.toggle.option('showtabline', { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = 'Tabline' })
    :map '<leader>uA'
Snacks.toggle.treesitter():map '<leader>uT'
Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
Snacks.toggle.dim():map '<leader>uD'
Snacks.toggle.animate():map '<leader>ua'
Snacks.toggle.indent():map '<leader>ug'
Snacks.toggle.scroll():map '<leader>uS'
Snacks.toggle.profiler():map '<leader>dpp'
Snacks.toggle.profiler_highlights():map '<leader>dph'

if vim.lsp.inlay_hint then
  Snacks.toggle.inlay_hints():map '<leader>uh'
end

-- highlights under cursor
map('n', '<leader>ui', vim.show_pos, { desc = 'Inspect Pos' })
map('n', '<leader>uI', function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input 'I'
end, { desc = 'Inspect Tree' })

-- Vimscript mappings
vim.g.table_mode_map_prefix = '<leader>ut'

-- Save with Ctrl+s
map('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save' })
map('i', '<C-s>', '<cmd>w<CR>', { desc = 'Save' })

-- vim: ts=2 sts=2 sw=2 et
