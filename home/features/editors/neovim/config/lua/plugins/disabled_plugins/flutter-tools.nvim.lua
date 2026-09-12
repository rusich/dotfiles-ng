return {
  'nvim-flutter/flutter-tools.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim', -- optional for vim.ui.select
  },
  event = 'VeryLazy',
  priority = 1000,
  opts = {
    debugger = { -- integrate with nvim dap + install dart code debugger
      enabled = true,
    },
    dev_log = {
      enabled = false,
      focus_on_open = false,
    },
    outline = {
      open_cmd = '60vnew', -- command to use to open the outline buffer
      auto_open = true, -- if true this will open the outline automatically when it is first populated
    },
    dev_tools = {
      autostart = true, -- autostart devtools server if not detected
      auto_open_browser = false, -- Automatically opens devtools in the browser
    },
    lsp = {
      color = { -- show the derived colours for dart variables
        enabled = true, -- whether or
        background = false,
        virtual_text = true,
      },
    },
  },
  config = function(_, opts)
    require('flutter-tools').setup(opts)
    -- autocommant for auto set width for outline window
    vim.api.nvim_create_autocmd('WinEnter', {
      pattern = '*',
      callback = function()
        if vim.bo.filetype == 'flutterToolsOutline' then
          -- set width to 60
          vim.cmd 'vertical resize 60'
        end
      end,
    })
  end,
}
