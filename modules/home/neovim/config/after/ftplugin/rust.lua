print 'hello from rust ftplugin'
vim.keymap.set('n', 'J', '<cmd>RustLsp joinLines<CR>')
vim.keymap.set('n', '<leader>ce', '<cmd>RustLsp explainError<CR>', { desc = 'Rust: Explain error' })
