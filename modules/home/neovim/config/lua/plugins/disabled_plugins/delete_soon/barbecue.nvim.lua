-- NOTE: Replaced with dropbar.nvim
-- Visual Studio Code inspired breadcrumbs plugin for the Neovim editor

---@type LazyPluginSpec
local specs = {
  'utilyre/barbecue.nvim',
  name = 'barbecue',
  event = 'LspAttach',
  version = '*',
  dependencies = {
    'SmiteshP/nvim-navic',
  },
  opts = {
    -- configurations go here
  },
}

return specs
