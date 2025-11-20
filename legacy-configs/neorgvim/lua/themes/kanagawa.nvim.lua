local spec = {
  'rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('kanagawa').setup {
      options = {
        dim_inactive = false, -- Non focused panes set to alternative background
      },
    }
  end,
}

return spec
