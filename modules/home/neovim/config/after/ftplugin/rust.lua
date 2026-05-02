print 'hello from rust ftplugin'
vim.keymap.set('n', 'J', '<cmd>RustLsp joinLines<CR>')
vim.keymap.set('n', '<leader>ce', '<cmd>RustLsp explainError<CR>', { desc = 'Rust: Explain error' })

vim.keymap.set(
  'n',
  'K', -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
  function()
    vim.cmd.RustLsp { 'hover', 'actions' }
  end,
  { silent = true, buffer = bufnr }
)
