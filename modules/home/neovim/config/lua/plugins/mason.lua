local spec = {
  'mason-org/mason-lspconfig.nvim',
  opts = {
    ensure_installed = {
      'rust_analyzer',
      'bashls',
      'omnisharp',
      'jsonls',
      'ts_ls',
      'nil_ls',
      'pyright',
      'lua_ls@3.16.4',
    },
  },
  dependencies = {
    {
      'mason-org/mason.nvim',
      opts = {
        registries = {
          'github:mason-org/mason-registry',
          'github:Crashdummyy/mason-registry',
        },
      },
    },
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      opts = {
        -- enabl
        ensure_installed = {
          -- DAP: enable it in ./debug.lua
          'netcoredbg',
          'codelldb',
          'debugpy',
          -- Linters: enable it in ./nvim-lint.lua
          'sqlfluff',
          'jsonlint',
          'shellcheck',
          -- Formatters: enable it in  ./conform.lua
          'alejandra',
          'sql-formatter',
          'csharpier',
          'prettier',
          'stylua',
          'shfmt',
        },
      },
    },
    'neovim/nvim-lspconfig',
  },
}

return spec
