" packadd hop.nvim
" packadd vim-wordmotion

set relativenumber
set number
set mouse=a
set clipboard=unnamedplus
set virtualedit=all

lua << EOF
-- space as the leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- require'hop'.setup()
-- vim.api.nvim_set_keymap("n", "<leader>ow", "<cmd>lua require'hop'.hint_words()<cr>", {})
-- vim.api.nvim_set_keymap("n", "<leader>or", "<cmd>lua require'hop'.hint_lines()<cr>", {})

EOF
" go to EOF
autocmd BufReadPost * normal G
