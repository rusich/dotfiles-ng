local dprefix = 'Rust: '

-- join lines
vim.keymap.set('n', 'J', function()
  vim.cmd.RustLsp { 'joinLines' }
end, { silent = true, buffer = 0, desc = dprefix .. 'Join lines' })

-- explain error
vim.keymap.set('n', '<leader>ce', function()
  vim.cmd.RustLsp { 'explainError' }
end, { silent = true, buffer = 0, desc = dprefix .. 'Explain error' })

-- hover actions
vim.keymap.set(
  'n',
  'K', -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
  function()
    vim.cmd.RustLsp { 'hover', 'actions' }
  end,
  { silent = true, buffer = 0, desc = dprefix .. 'Hover actions' }
)

-- expand macro
vim.keymap.set('n', '<leader>cm', function()
  vim.cmd.RustLsp { 'expandMacro' }
end, { silent = true, buffer = 0, desc = dprefix .. 'Expand macro' })

-- related tests
vim.keymap.set('n', '<leader>ct', function()
  vim.cmd.RustLsp { 'relatedTests' }
end, { silent = true, buffer = 0, desc = dprefix .. 'Related tests' })

-- open cargo
vim.keymap.set('n', '<leader>cc', function()
  vim.cmd.RustLsp { 'openCargo' }
end, { silent = true, buffer = 0, desc = dprefix .. 'Open cargo' })

-- open docs
vim.keymap.set('n', '<leader>cd', function()
  vim.cmd.RustLsp { 'openDocs' }
end, { silent = true, buffer = 0, desc = dprefix .. 'Open docs' })
