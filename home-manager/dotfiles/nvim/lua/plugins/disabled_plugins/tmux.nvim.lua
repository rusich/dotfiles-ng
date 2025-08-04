-- Integrate nvim with tmux

local spec = {
  'aserowy/tmux.nvim',
  lazy = false,
  config = true,
  opts = {
    copy_sync = {
      enable = false,
    },
  },
}

return spec
