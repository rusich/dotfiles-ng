-- Highlight, edit, and navigate code

---@type LazyPluginSpec
local spec = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = { 'python', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'typst', 'rust', 'vim', 'vimdoc', 'yaml', 'latex' },
    ignore_install = { 'org' },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true, disable = { 'ruby' } },
    -- helix-like treesitter selection
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<M-o>",
        scope_incremental = "<M-O>",
        node_incremental = "<M-o>",
        node_decremental = "<M-i>",
      },
    },

  },
  config = function(_, opts)
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

    -- Prefer git instead of curl in order to improve connectivity in some environments
    require('nvim-treesitter.install').prefer_git = true
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup(opts)
  end,
}

return spec
-- vim: ts=2 sts=2 sw=2 et
