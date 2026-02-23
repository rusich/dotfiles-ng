---@type LazyPluginSpec
local spec = {
  'rasulomaroff/reactive.nvim',
  config = function()
    require('reactive').setup {
      load = { 'catppuccin-mocha-cursor', 'catppuccin-mocha-cursorline' },
      builtin = {
        cursorline = true,
        cursor = true,
        modemsg = true,
      },
    }
  end,
}

return spec
