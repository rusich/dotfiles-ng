-- Useful plugin to show you pending keybinds.

---@type LazyPluginSpec
local spec = {
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup {
      preset = 'helix',
    }

    -- Document existing key chains
    require('which-key').add {
      { '<leader>c',  group = 'Code' },
      { '<leader>s',  group = 'Search' },
      { '<leader>u',  group = 'ui' },
      { '<leader>ut', group = 'Table Mode' },
      { '<leader>g',  group = 'Git' },
      { '<leader>x',  group = 'Trouble' },
      { '<leader>a',  group = 'AI' },
      { '<leader>n',  group = 'Notes' },
      { '<leader>d',  group = 'Debug' },
      { '<leader>O',  group = 'org' },
      { '<leader>up', group = 'Paste' },
      { '<leader>f',  group = 'Find' },
      { '<leader>f',  group = 'Find' },
    }
  end,
}

return spec
-- vim: ts=2 sts=2 sw=2 et
