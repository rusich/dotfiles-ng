---@type LazyPluginSpec
local spec = {
  'aznhe21/actions-preview.nvim',
  config = function()
    local hl = require 'actions-preview.highlight'

    require('actions-preview').setup {
      -- highlight_command = {
      -- hl.delta 'delta --no-gitconfig --side-by-side',
      -- hl.delta 'delta --no-gitconfig',
      --   hl.diff_so_fancy,
      -- },
      -- telescope = {
      --   sorting_strategy = 'ascending',
      --   layout_strategy = 'vertical',
      --   layout_config = {
      --     width = 0.8,
      --     height = 0.9,
      --     prompt_position = 'top',
      --     preview_cutoff = 20,
      --     preview_height = function(_, _, max_lines)
      --       return max_lines - 15
      --     end,
      --   },
      -- },
      diff = {
        ctxlen = 3,
      },
      -- backend = { 'telescope' },
      backend = { 'snacks' },
    }
  end,
  keys = {
    {
      '<A-.>',
      "<cmd>lua require('actions-preview').code_actions()<cr>",
      mode = { 'n', 'v' },
      desc = 'Code Actions',
    },
  },
}

return spec
