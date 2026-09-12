---@type LazyPluginSpec
local spec = {
  'dhruvasagar/vim-table-mode',
  lazy = true,
  ft = 'markdown',
  keys = {
    -- { '<leader>ut', '<cmd>TableModeEnable<cr>', desc = 'Enable table mode' },
  },
  -- config = function()
  -- vim.cmd 'TableModeEnable'
  -- end,
  init = function()
    vim.g.table_mode_corner = '|'
    vim.g.table_mode_map_prefix = '<leader>ut'
  end

}

return spec
