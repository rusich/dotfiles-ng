-- Collection of various small independent plugins/modules

local set = vim.keymap.set

local spec = {
  'nvim-mini/mini.nvim',
  lazy = false,
  config = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniStarterOpened',
      callback = function()
        require('mini.clue').ensure_buf_triggers()
      end,
    })
    -- TEXT EDITING --

    -- Better Around/Inside textobjects
    --
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    -- require('mini.ai').setup { n_lines = 500 }

    -- comments
    require('mini.comment').setup()

    -- move text to any directions (Alt+direction key)
    require('mini.move').setup()

    -- autopairs
    require('mini.pairs').setup {

      modes = { insert = true, command = true, terminal = false, normal = false },
    }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- -- Setup
    -- local gen_loader = require('mini.snippets').gen_loader
    -- require('mini.snippets').setup {
    --   snippets = {
    --     -- gen_loader.from_runtime '*.json',
    --     -- Load custom file with global snippets first
    --     gen_loader.from_file '~/.config/nvim/snippets/global.json',
    --
    --     -- Load snippets based on current language by reading files from
    --     -- "snippets/" subdirectories from 'runtimepath' directories.
    --     gen_loader.from_lang(),
    --   },
    -- }

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
    -- TODO: read manual
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

    require('mini.indentscope').setup {
      draw = { delay = 1 },
      symbol = '│',
    }

    -- STATUSL_INE START
    local statusline = require 'mini.statusline'

    local opts = {
      content = {
        active = function()
          -- SECTIONS
          local section_mode = function(args)
            local modes = {
              ['n'] = { text = 'N', hl = 'MiniStatuslineModeNormal' },
              ['v'] = { text = 'V', hl = 'MiniStatuslineModeVisual' },
              ['V'] = { text = 'V-L', hl = 'MiniStatuslineModeVisual' },
              [''] = { text = 'V-B', hl = 'MiniStatuslineModeVisual' },
              ['s'] = { text = 'S', hl = 'MiniStatuslineModeVisual' },
              ['S'] = { text = 'S-L', hl = 'MiniStatuslineModeVisual' },
              [''] = { text = 'S-B', hl = 'MiniStatuslineModeVisual' },
              ['i'] = { text = 'I', hl = 'MiniStatuslineModeInsert' },
              ['R'] = { text = 'R', hl = 'MiniStatuslineModeReplace' },
              ['c'] = { text = 'C', hl = 'MiniStatuslineModeCommand' },
              ['r'] = { text = 'P', hl = 'MiniStatuslineModeOther' },
              ['!'] = { text = 'Sh', hl = 'MiniStatuslineModeOther' },
              ['t'] = { text = 'T', hl = 'MiniStatuslineModeOther' },
            }

            local mode_info = modes[vim.fn.mode()]
            local mode = '  ' .. mode_info.text
            return mode, mode_info.hl
          end

          local section_diff = function()
            local diff = MiniStatusline.section_diff { trunc_width = 75 }
            if diff:find '%+' then
              diff = diff:gsub('%+', '%%#SL_DiffAdd#+')
            end
            if diff:find '%~' then
              diff = diff:gsub('%~', '%%#SL_DiffChange#~')
            end
            if diff:find '%-' then
              diff = diff:gsub('%-', '%%#SL_DiffDelete#-')
            end
            return diff
          end

          local section_lsp = function()
            if MiniStatusline.is_truncated(75) then
              return ''
            end

            local bufnr = vim.api.nvim_get_current_buf()
            local clients = vim.lsp.get_clients { bufnr = bufnr }

            if #clients == 0 then
              return ''
            end

            local current_clients = {}
            for _, client in ipairs(clients) do
              table.insert(current_clients, client.name)
            end

            return ' ' .. table.concat(current_clients, '|')
          end

          local section_fileformat = function()
            local fileformat = vim.o.fileformat
            local symbols = {
              unix = '', -- e712
              dos = '', -- e70f
              mac = '', -- e711
            }
            return symbols[fileformat]
          end

          local section_filesize = function()
            local size = math.max(vim.fn.line2byte(vim.fn.line '$' + 1) - 1, 0)
            if size < 1024 then
              return string.format('%dB', size)
            elseif size < 1048576 then
              return string.format('%.1fK', size / 1024)
            else
              return string.format('%.1fM', size / 1048576)
            end
          end

          local function section_location()
            local pos = vim.api.nvim_win_get_cursor(0)
            local row = pos[1]
            local col = pos[2] + 1

            local total = vim.api.nvim_buf_line_count(0)
            local progress = math.floor((row / total) * 100)

            return string.format('%d:%d %d%%%%', row, col, progress)
          end

          -- HIGHLIGHTS
          local utils = require 'utils'
          local colors = {
            bg = utils.color.get_hl_color('NormalFloat', 'bg'),
            fg = utils.color.get_hl_color('NormalFloat', 'fg'),
            inactive_fg = utils.color.get_hl_color('StatusLineNC', 'fg'),
            yellow = '#ECBE7B',
            cyan = '#7AA79F',
            green = '#98BB6C',
            orange = '#FF9F65',
            violet = '#a9a1e1',
            magenta = '#c678dd',
            blue = '#7E9CD8',
            red = '#ec5f67',
          }
          vim.api.nvim_set_hl(0, 'StatusLine', { bg = colors.bg, fg = colors.fg })
          vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = colors.bg, fg = colors.inactive_fg })
          vim.api.nvim_set_hl(0, 'MiniStatuslineModeNormal', { fg = colors.red, bg = colors.bg })
          vim.api.nvim_set_hl(0, 'MiniStatuslineModeVisual', { fg = colors.blue, bg = colors.bg })
          vim.api.nvim_set_hl(0, 'MiniStatuslineModeInsert', { fg = colors.green, bg = colors.bg })
          vim.api.nvim_set_hl(0, 'MiniStatuslineModeReplace', { fg = colors.violet, bg = colors.bg })
          vim.api.nvim_set_hl(0, 'MiniStatuslineModeCommand', { fg = colors.magenta, bg = colors.bg })
          vim.api.nvim_set_hl(0, 'MiniStatuslineModeOther', { fg = colors.cyan, bg = colors.bg })
          vim.api.nvim_set_hl(0, 'MiniStatuslineModeInactive', { fg = colors.bg, bg = colors.fg })
          vim.api.nvim_set_hl(0, 'SL_DiagError', { fg = colors.red })
          vim.api.nvim_set_hl(0, 'SL_DiagWarn', { fg = colors.yellow })
          vim.api.nvim_set_hl(0, 'SL_DiagInfo', { fg = colors.violet })
          vim.api.nvim_set_hl(0, 'SL_DiagHint', { fg = colors.cyan })
          vim.api.nvim_set_hl(0, 'SL_LspInfo', { fg = colors.green, bold = false })
          vim.api.nvim_set_hl(0, 'SL_Git', { fg = colors.orange, bold = true })
          vim.api.nvim_set_hl(0, 'SL_DiffAdd', { fg = colors.green })
          vim.api.nvim_set_hl(0, 'SL_DiffChange', { fg = colors.orange })
          vim.api.nvim_set_hl(0, 'SL_DiffDelete', { fg = colors.red })
          vim.api.nvim_set_hl(0, 'SL_Codeium', { fg = colors.magenta })
          vim.api.nvim_set_hl(0, 'SL_Encoding', { fg = colors.yellow })
          vim.api.nvim_set_hl(0, 'SL_fileinfo', { fg = colors.fg, bold = true })

          local git = MiniStatusline.section_git { trunc_width = 40 }
          local diagnostics = MiniStatusline.section_diagnostics {
            trunc_width = 75,
            signs = { ERROR = '%#SL_DiagError# ', WARN = '%#SL_DiagWarn# ', INFO = '%#SL_DiagInfo# ', HINT = '%#SL_DiagHint# ' },
          }
          local filename = MiniStatusline.section_filename { trunc_width = 140 }
          local search = MiniStatusline.section_searchcount { trunc_width = 75 }

          local mode, mode_hl = section_mode { trunc_width = 120 }
          return MiniStatusline.combine_groups {
            { hl = mode_hl, strings = { mode } },
            { hl = 'SL_Git', strings = { git, '%#StatusLineNC#', section_diff(), '%#StatusLineNC#', diagnostics, '%*' } },
            '%<', -- Mark general truncate point
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=', -- End left alignment
            { hl = 'IncSearch', strings = { search } },
            { hl = 'SL_LspInfo', strings = { section_lsp() } },
            -- { hl = 'SL_LspInfo', strings = { lsp } },
            { hl = 'SL_Codeium', strings = { '{…}' .. vim.api.nvim_call_function('codeium#GetStatusString', {}) } },
            -- { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
            { hl = 'SL_Encoding', strings = { string.upper(vim.o.fileencoding) } },
            { hl = 'StatusLineNC', strings = { section_fileformat() } },
            { hl = 'SL_fileinfo', strings = { section_filesize(), section_location() } },
            ' ',
          }
        end,
      },
    }
    statusline.setup(opts)
    -- statusline.setup()
    --- STATUSLINE END

    -- Whichkey replacement
    local miniclue = require 'mini.clue'
    miniclue.setup {

      window = {
        -- Show window immediately
        delay = 0,
      },
      triggers = {
        -- Leader triggers
        {
          mode = { 'n', 'x' },
          keys = '<Leader>',
        },

        { mode = 'n', keys = 'c' },

        -- `[` and `]` keys
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },

        -- Built-in completion
        { mode = 'i', keys = '<C-x>' },

        -- `g` key
        { mode = { 'n', 'x' }, keys = 'g' },

        -- Marks
        { mode = { 'n', 'x' }, keys = "'" },
        { mode = { 'n', 'x' }, keys = '`' },

        -- Registers
        { mode = { 'n', 'x' }, keys = '"' },
        { mode = { 'i', 'c' }, keys = '<C-r>' },

        -- Window commands
        { mode = 'n', keys = '<C-w>' },

        -- `z` key
        { mode = { 'n', 'x' }, keys = 'z' },
      },

      clues = {
        -- Enhance this by adding descriptions for <Leader> mapping groups
        miniclue.gen_clues.square_brackets(),
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),

        { mode = 'n', keys = '<Leader>c', desc = '+Code' },
        { mode = 'n', keys = '<Leader>s', desc = '+Search' },
        { mode = 'n', keys = '<Leader>u', desc = '+ui' },
        { mode = 'n', keys = '<Leader>ut', desc = '+Table Mode' },
        { mode = 'n', keys = '<Leader>g', desc = '+Git' },
        { mode = 'n', keys = '<Leader>x', desc = '+Trouble' },
        { mode = 'n', keys = '<Leader>a', desc = '+AI' },
        { mode = 'n', keys = '<Leader>n', desc = '+Notes' },
        { mode = 'n', keys = '<Leader>d', desc = '+Debug' },
        { mode = 'n', keys = '<Leader>O', desc = '+org' },
        { mode = 'n', keys = '<Leader>up', desc = '+Paste' },
        { mode = 'n', keys = '<Leader>f', desc = '+Find' },
        { mode = 'n', keys = '<Leader>t', desc = '+Tests' },
      },
    }

    -- leap-like
    require('mini.jump').setup {
      mappings = { repeat_jump = '' },
    }

    -- Restore original ; and , behavior
    vim.keymap.set('n', ';', function()
      if MiniJump.state.backward then
        MiniJump.jump(nil, true)
        MiniJump.state.backward = true
      else
        MiniJump.jump(nil, false)
        MiniJump.state.backward = false
      end
    end)

    vim.keymap.set('n', ',', function()
      if not MiniJump.state.backward then
        MiniJump.jump(nil, true)
        MiniJump.state.backward = false
      else
        MiniJump.jump(nil, false)
        MiniJump.state.backward = true
      end
    end)

    require('mini.jump2d').setup {
      view = {
        -- Whether to dim lines with at least one jump spot
        dim = true,
        -- How many steps ahead to show. Set to big number to show all steps.
        n_steps_ahead = 5,
      },

      -- Which lines are used for computing spots
      allowed_lines = {
        blank = false, -- Blank line (not sent to spotter even tf `true`)
        fold = true, -- Start of fold (not sent to spotter even if `true`)
      },

      mappings = {
        start_jumping = '',
      },
    }
    -- NOTE: заменяет стандартных хоткей 'gw'
    vim.keymap.set('n', 'gw', '<Cmd>lua   MiniJump2d.start(MiniJump2d.builtin_opts.word_start)<CR>', { silent = true })
    local function set_mini_jump_hl()
      local spot_color = '#ff5d62'
      vim.api.nvim_set_hl(0, 'MiniJump', { foreground = spot_color, bold = true })
      vim.api.nvim_set_hl(0, 'MiniJump2dSpot', { foreground = spot_color, bold = true })
      vim.api.nvim_set_hl(0, 'MiniJump2dSpotAhead', { foreground = spot_color, bold = true })
      vim.api.nvim_set_hl(0, 'MiniJump2dSpotUnique', { foreground = spot_color, bold = true })
    end
    -- Устанавливаем highlight сразу
    set_mini_jump_hl()
    -- Автокоманда для ColorScheme, которая выполнится с задержкой после автокоманды MiniJump2d
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('MyMiniJumpHL', { clear = true }),
      pattern = '*',
      callback = function()
        -- Используем vim.schedule для гарантии выполнения после автокоманды MiniJump2d
        vim.schedule(function()
          set_mini_jump_hl()
        end)
      end,
      desc = 'Set MiniJump highlight after colorscheme change',
    })
  end,
}

return spec
-- vim: ts=2 sts=2 sw=2 et
