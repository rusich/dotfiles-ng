local spec = {
  'rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    -- theme = 'wawe',
    theme = 'dragon',
    -- theme = 'lotus',
    dimInactive = false,
    colors = {
      theme = {
        all = {
          ui = {
            bg_gutter = 'none',
          },
        },
      },
    },
  },
}

return spec
