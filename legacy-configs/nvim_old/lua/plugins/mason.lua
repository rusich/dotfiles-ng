local spec = {
  'mason-org/mason-lspconfig.nvim',
  opts = {
    ensure_installed = { 'rust_analyzer', 'bashls', 'lua_ls' },
  },
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'neovim/nvim-lspconfig',
  },
}

return spec
