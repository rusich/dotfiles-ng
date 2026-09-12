-- A small Neovim plugin for previewing definitions using floating windows.

---@type LazyPluginSpec
local spec = {
  'rmagatti/goto-preview',
  -- event = 'LspAttach',

  keys = {
    {
      'gp',
      function()
        require('goto-preview').goto_preview_definition {}
      end,
      mode = 'n',
      desc = 'Preview definition',
    },
  },
  config = true,
  opts = {
    border = { '↖', '─', '╮', '│', '╯', '─', '╰', '│' },
  },
}

return spec
