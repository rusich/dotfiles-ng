-- Collection of various small independent plugins/modules

local set = vim.keymap.set

---@type LazyPluginSpec
local spec = {
  'echasnovski/mini.nvim',
  config = function()
    -- TEXT EDITING --

    -- Better Around/Inside textobjects
    --
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- comments
    require('mini.comment').setup()

    -- move text to any directions (Alt+direction key)
    require('mini.move').setup()

    -- autopairs
    require('mini.pairs').setup {

      modes = { insert = true, command = true, terminal = false },
    }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Setup
    local gen_loader = require('mini.snippets').gen_loader
    require('mini.snippets').setup {
      snippets = {
        -- gen_loader.from_runtime '*.json',
        -- Load custom file with global snippets first
        gen_loader.from_file '~/.config/nvim/snippets/global.json',

        -- Load snippets based on current language by reading files from
        -- "snippets/" subdirectories from 'runtimepath' directories.
        gen_loader.from_lang(),
      },
    }

    -- GENERAL WORKFLOW --

    -- -- navigate with ][
    -- require('mini.bracketed').setup()

    -- Save window layout when buffer removed
    require('mini.bufremove').setup()
    vim.cmd 'cabbrev bd lua require("mini.bufremove").delete()'
    vim.cmd 'cabbrev bD lua require("mini.bufremove").delete(0, true) '

    -- files
    require('mini.files').setup {}
    set('n', '\\', '<cmd>lua MiniFiles.open()<cr>', { desc = 'Navigate files' })

    -- Extra pickers, textobjects, etc
    require('mini.extra').setup()

    -- Git
    require('mini.git').setup()
    require('mini.diff').setup {
      view = {
        signs = { add = '┃', change = '┃', delete = '‣' },
      },
    }
    vim.keymap.set('n', '<leader>gv', function()
      require('mini.diff').toggle_overlay(0)
    end, { desc = 'Preview changes' })

    -- Session manager
    require('mini.sessions').setup {}

    -- APPEARANCE --
    -- Cursorword
    vim.defer_fn(function()
      vim.cmd 'highlight MiniCursorword gui=bold,underline cterm=bold,underline'
      vim.cmd 'highlight link MiniCursorwordCurrent MiniCursorword'
    end, 2000)
    require('mini.cursorword').setup()

    -- Highlight patterns in text/nvim-colorizer replacement
    local hipatterns = require 'mini.hipatterns'
    hipatterns.setup {
      highlighters = {
        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

    -- enable icons
    require('mini.icons').setup()
    MiniIcons.mock_nvim_web_devicons()

    -- indentscope
    require('mini.indentscope').setup {
      draw = { delay = 1 },
      symbol = '│',
    }

    -- -- statusline -- Lualine is better
    -- require('mini.statusline').setup {
    --   content = {
    --     -- Content for active window
    --     active = nil,
    --   },
    -- }
  end,
}

return spec
-- vim: ts=2 sts=2 sw=2 et
