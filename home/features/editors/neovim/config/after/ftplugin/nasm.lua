-- Use spaces instead of tabs for alignment
vim.b.editorconfig = false

vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 8
vim.opt_local.tabstop = 8
vim.opt_local.softtabstop = 8

-- Важно: выключаем все движки, кроме базового autoindent
vim.opt_local.smartindent = false
vim.opt_local.cindent = false
vim.opt_local.indentexpr = ''
vim.opt_local.autoindent = true

-- Удаляем триггеры 'o' и 'O', которые сбрасывали отступ при создании строки
vim.opt_local.indentkeys:remove { 'o', 'O' }
vim.opt_local.cinkeys:remove { 'o', 'O' }
