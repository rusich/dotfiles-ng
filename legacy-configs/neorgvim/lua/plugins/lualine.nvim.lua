-- A blazing fast and easy to configure Neovim statusline written in Lua.

local spec = {
  'nvim-lualine/lualine.nvim',
  event = 'BufEnter',

  config = function()
    local utils = require 'utils'

    -- Color table for highlights
    -- stylua: ignore
    local colors = {
      bg = utils.color.get_hl_color('NormalFloat', 'bg'),
      fg = utils.color.get_hl_color('NormalFloat', 'fg'),
      yellow = '#ECBE7B',
      cyan = '#7AA79F',
      green = '#98BB6C',
      orange = '#FF9F65',
      violet = '#a9a1e1',
      magenta = '#c678dd',
      blue = '#7E9CD8',
      red = '#ec5f67',
    }

    -- Eviline config for lualine
    -- Author: shadmansaleh
    -- Credit: glepnir
    local lualine = require 'lualine'

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand '%:t') ~= 1
      end,
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
      check_git_workspace = function()
        local filepath = vim.fn.expand '%:p:h'
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
      end,
    }

    -- Config
    local config = {
      options = {
        globalstatus = true,
        ignore_focus = {
          -- 'TelescopePrompt',
          'neo-tree',
          'trouble',
        },
        disabled_filetypes = { -- Filetypes to disable lualine for.
          statusline = {
            'snacks_dashboard',
            -- '',
          },
          winbar = {},
        },
        -- Disable sections and component separators
        component_separators = '',
        section_separators = '',
        theme = {
          -- We are going to use lualine_c an lualine_x as left and
          -- right section. Both are highlighted by c theme .  So we
          -- are just setting default looks o statusline
          normal = { c = { fg = colors.fg, bg = colors.bg } },
          inactive = { c = { fg = colors.fg, bg = colors.bg } },
        },
        -- theme = 'catppuccin',
      },
      sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_x = {},
      },
      inactive_sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
      },
    }

    -- Inserts a component in lualine_c at left section
    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end

    -- Inserts a component in lualine_x at right section
    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    ins_left {
      function()
        -- return '▊'
        return ' '
      end,
      color = { fg = colors.blue },      -- Sets highlighting of component
      padding = { left = 0, right = 1 }, -- We don't need space before this
    }

    ins_left {
      -- mode component
      function()
        return ' ' .. string.upper(vim.fn.mode())
      end,
      color = function()
        -- auto change color according to neovims mode
        local mode_color = {
          n = colors.red,
          i = colors.green,
          v = colors.blue,
          [''] = colors.blue,
          V = colors.blue,
          c = colors.magenta,
          no = colors.red,
          s = colors.orange,
          S = colors.orange,
          [''] = colors.orange,
          ic = colors.yellow,
          R = colors.violet,
          Rv = colors.violet,
          cv = colors.red,
          ce = colors.red,
          r = colors.cyan,
          rm = colors.cyan,
          ['r?'] = colors.cyan,
          ['!'] = colors.red,
          t = colors.red,
        }
        return { fg = mode_color[vim.fn.mode()] }
      end,
      padding = { right = 1 },
    }

    ins_left {
      -- filesize component
      'filesize',
      cond = conditions.buffer_not_empty,
    }

    ins_left {
      'filename',
      cond = conditions.buffer_not_empty,
      color = { fg = colors.blue, gui = 'bold' },
    }

    ins_left {
      'branch',
      icon = '',
      color = { fg = colors.orange, gui = 'bold' },
    }

    ins_left {
      'diff',
      -- Is it me or the symbol for modified us really weird
      symbols = { added = '+', modified = '~', removed = '-' },
      diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red },
      },
      cond = conditions.hide_in_width,
    }

    ins_left {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      symbols = { error = ' ', warn = ' ', info = ' ' },
      icon = '!',
      diagnostics_color = {
        error = { fg = colors.red },
        warn = { fg = colors.yellow },
        info = { fg = colors.cyan },
      },
    }

    ins_left {
      'searchcount',
    }

    -- Insert mid section. You can make any number of sections in neovim :)
    -- for lualine it's any number greater then 2
    ins_left {
      function()
        return '%='
      end,
    }

    ins_right {
      -- Lsp server name .
      function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients { bufnr = bufnr }

        if #clients == 0 then
          return 'No LSP'
        end

        local current_clients = {}
        for _, client in ipairs(clients) do
          table.insert(current_clients, client.name)
        end

        return table.concat(current_clients, '|')
      end,
      icon = '',
      color = { fg = colors.green, gui = 'bold' },
    }

    ins_right {
      function()
        --
        return '{…}' .. vim.api.nvim_call_function('codeium#GetStatusString', {})
      end,
      color = { fg = colors.magenta },
    }

    -- FIXME: сейчас работает только для Hyprland, добавить поддержку Niri
    -- ins_right {
    --   function()
    --     return '󰌌 ' .. vim.g.last_input_kb_layout
    --   end,
    --   color = { fg = colors.cyan, gui = 'bold' },
    -- }

    -- Add components to right sections
    ins_right {
      'o:encoding',       -- option component same as &encoding in viml
      fmt = string.upper, -- I'm not sure why it's upper case either ;)
      cond = conditions.hide_in_width,
      color = { fg = colors.yellow, gui = 'bold' },
    }

    ins_right {
      'fileformat',
      symbols = {
        unix = '', -- e712
        dos = '', -- e70f
        mac = '', -- e711
      },
      color = { fg = colors.violet, gui = 'bold' },
    }

    ins_right { 'location' }

    ins_right { 'progress', color = { fg = colors.fg, gui = 'bold' } }

    ins_right {
      function()
        -- return '▊'
        return ' '
      end,
      color = { fg = colors.blue },
      padding = { left = 1 },
    }

    -- Now don't forget to initialize lualine
    lualine.setup(config)
  end,
}

return spec
