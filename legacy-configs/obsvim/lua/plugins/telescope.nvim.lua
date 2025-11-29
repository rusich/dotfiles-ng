---@type LazyPluginSpec
local spec = {
  -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  config = function()
    require('telescope').setup {
      defaults = require("telescope.themes").get_ivy({
        layout_config = { height = 0.30 },
      }),

    }
  end
}

return spec
-- vim: ts=2 sts=2 sw=2 et
