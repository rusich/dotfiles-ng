-- Modern database interface for Vim

---@type LazyPluginSpec
local spec = {
  'tpope/vim-dadbod',
  dependencies = {
    'kristijanhusak/vim-dadbod-ui',
    'kristijanhusak/vim-dadbod-completion',
    'nanotee/sqls.nvim',
  },
  cmd = { 'DB', 'DBUI', 'DBUIToggle' },
}

return spec
