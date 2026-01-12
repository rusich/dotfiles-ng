-- EMACS Orgmode clone written in Lua for Neovim 0.9+.

-- Helper functions
local ext = require 'plugins.ext.orgmode'

local spec = {
  {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    keys = {
      { '<leader>Oa' },
      { '<leader>Oc' },
      { '<leader>OI' },
    },
    ft = { 'org' },
    dependencies = {
      'danilshvalov/org-modern.nvim',
    },
    config = function()
      --  meta return
      local set_cr_mapping = function()
        vim.keymap.set('n', '<C-CR>', '<cmd>lua require("orgmode").action("org_mappings.meta_return")<CR>', {
          silent = true,
          buffer = true,
        })
        vim.keymap.set('i', '<C-CR>', '<cmd>lua require("orgmode").action("org_mappings.meta_return")<CR>', {
          silent = true,
          buffer = true,
        })
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'org',
        callback = set_cr_mapping,
      })

      local Menu = require 'org-modern.menu'

      require('orgmode').setup {
        org_agenda_files = { '~/Nextcloud/org/**/*' },
        org_default_notes_file = '~/Nextcloud/org/inbox.org',
        org_capture_templates = {
          -- example:
          -- t = {
          --   description = 'Todo',
          --   template = '* TODO %?\n%U\n\n%a\n\nCustom prompt: %^{TEST_PROMPT|DEFAULT_VALUE|One|Two|Three}',
          --   target = '~/Nextcloud/org/Inbox.org',
          -- },
          -- t = {
          --   description = 'Todo',
          --   template = '* TODO %?\n%U\n\n%a\n\nCustom prompt: %^{TEST_PROMPT|DEFAULT_VALUE|One|Two|Three}',
          --   target = '~/Nextcloud/org/inbox.org',
          -- },
          t = {
            description = 'Todo',
            template = '* TODO %?\n\nPlanned: %U\n\n',
            target = '~/Nextcloud/org/inbox.org',
          },
        },
        org_hide_emphasis_markers = true,
        org_log_into_drawer = 'LOGBOOK',
        org_todo_keywords = {
          'TODO(t)',
          'NEXT(n)',
          'WAITING(w)',
          'SOMEDAY(s)',
          'PROJECT(p)',
          'LEARNING(l)',
          '|',
          'CANCELED(c)',
          'DONE(d)',
          -- 'WORK(r)',
        },
        org_todo_repeat_to_state = 'NEXT(n)',
        org_todo_keyword_faces = {
          TODO = ':foreground #ff005d :weight bold',
          NEXT = ':foreground magenta :weight bold',
          WAITING = ':foreground orange :weight bold',
          SOMEDAY = ':foreground #006bed :weight bold',
          PROJECT = ':foreground #ffe600 :weight bold',
          LEARNING = ':foreground yellow :weight bold',
          --
          CANCELED = ':background gray :foreground black :slant italic :underline on',
          DONE = ':foreground #2df74e :weight bold',
        },

        org_startup_folded = 'inherit',
        -- org_log_done = 'note',
        org_log_repeat = 'time',
        org_ellipsis = '⤵',
        org_id_link_to_org_use_id = true,
        org_deadline_warning_days = 7,
        -- org_agenda_text_search_extra_files = { 'agenda-archives' },
        org_use_tag_inheritance = true,
        mappings = {

          prefix = "<leader>O",
          org = {
            org_archive_subtree = '<leader>O?',
          },
          capture = {
            org_capture_kill = 'q',
          },
          note = {
            org_note_kill = 'q',
          },
        },
        -- Modern agenda ui
        ui = {
          input = {
            use_vim_ui = true,
          },
          menu = {
            handler = function(data)
              Menu:new({
                window = {
                  margin = { 1, 0, 1, 0 },
                  padding = { 0, 1, 0, 1 },
                  title_pos = 'center',
                  border = 'rounded',
                  zindex = 1000,
                },
                icons = {
                  separator = '➜',
                },
              }):open(data)
            end,
          },
        },
        -- Notifications test
        notifications = {
          -- enabled = true, --popup
          cron_enabled = true,
          reminder_time = { 30, 60 },
          -- repeater_reminder_time = { 0, 1, 5, 10 },
          deadline_warning_reminder_time = { 10, 30 },
          cron_notifier = function(tasks)
            for _, task in ipairs(tasks) do
              local title = string.format('%s (%s)', task.category, task.humanized_duration)
              local subtitle = string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title)
              local date = string.format('%s: %s', task.type, task.time:to_string())

              if vim.fn.executable 'notify-send' then
                vim.loop.spawn('notify-send', {
                  args = {
                    '--icon=/home/rusich/Nextcloud/Pictures/Icons/nvim-orgmode-small.png',
                    '--app-name=orgmode',
                    '--urgency=critical',
                    string.format('%s', title),
                    string.format('%s\n%s', date, subtitle),
                  },
                })
              end
            end
          end,
        },
      }

      -- Custom mappings
      vim.keymap.set('n', '<leader>OI', '<cmd>e ~/Nextcloud/org/inbox.org<cr>', { desc = 'Open Inbox' })
      vim.keymap.set('n', '<leader>O$', ext.archive_to_daily, { desc = 'Archive heading' }) -- Replace origina archive function
    end,
  },
  {
    lazy = true,
    ft = 'org',
    'chipsenkbeil/org-roam.nvim',
    keys = { { '<leader>ON' } },
    -- lazy = false,
    -- tag = '0.1.0',
    dependencies = {
      {
        'nvim-orgmode/orgmode',
        -- tag = '0.3.4',
      },
      'sudo-burger/cmp-org-roam',
    },
    config = function()
      require('org-roam').setup {
        directory = '~/Nextcloud/org/notes/',
        ui = {
          node_buffer = {
            show_keybindings = false,
            -- unique = true,
            -- open = 'botright split | resize 10',
          },
        },
        bindings = {
          prefix = '<leader>ON',
        },
        -- optional
        org_files = {
          '~/Nextcloud/org/*.org',
          --   '~/another_org_dir',
          --   '~/some/folder/*.org',
          --   '~/a/single/org_file.org',
        },
        templates = {
          d = {
            description = 'default',
            -- template = '%f %t %a %x  %?', -- %f - file_from, %t - current date, %a - file_from with line number, %x - clipboard content
            template = '#+CATEGORY: %?\n#+FILETAGS: :%?:\n\n',
            -- target = '%[slug]-%<%Y%m%d%H%M%S>.org',
            target = '%[slug]-%<%Y%m%d>.org',
          },
          b = {
            description = 'book notes',
            template = '\n* Source\n\nAuthor: %^{Author}\nTitle: ${title}\nYear: %^{Year},\n\n* Summary\n\n%?',
            target = '%[slug]-%<%Y%m%d%H%M%S>.org',
          },
        },

        immediate = {
          target = '%[slug]-%<%Y%m%d%H%M%S>.org',
        },
      }

      -- open quickfix list of links and backlingks for current Node (replace original)
      vim.keymap.set('n', '<leader>ONq', ext.qf_links_and_backlinks,
        { desc = 'Open quickfix list of links and backlinks for current node' })
      -- define <leader>Onr keymap to open quickfix list of links for current org-file
    end,
  },
  {
    'lukas-reineke/headlines.nvim',
    lazy = true,
    ft = { 'markdown', 'org' },
    opts = {
      markdown = {
        headline_highlights = false,
        codeblock_highlight = false,
        bullet_highlights = false,
        dash_highlight = false,
        quote_highlight = false,
      },
      org = {
        -- headline_highlights = false,
        headline_highlights = {
          'fake',
        },
        codeblock_highlight = 'RenderMarkdownCode',
        bullets = { '◉', '○', '◈', '◇', '✳' },
        fat_headlines = false,
        dash_highlight = 'Dash',
        dash_string = '-',
        quote_highlight = 'Quote',
        quote_string = '▋',
      },
    },
  },
  {
    'andreadev-it/orgmode-multi-key',
    lazy = true,
    ft = { 'org' },
    config = true,
  },
  -- {
  --   'BartSte/nvim-khalorg',
  --   dependencies = {
  --     'nvim-orgmode/orgmode',
  --   },
  --   config = function()
  --     require('khalorg').setup {
  --       calendar = 'personal',
  --     }
  --     local khalorg = require 'khalorg'
  --     local orgmode = require 'orgmode'
  --     ---@diagnostic disable-next-line: missing-fields
  --     orgmode.setup {
  --       org_custom_exports = {
  --         n = { label = 'Add a new khal item', action = khalorg.new },
  --         d = { label = 'Delete a khal item', action = khalorg.delete },
  --         e = { label = 'Edit properties of a khal item', action = khalorg.edit },
  --         E = { label = 'Edit properties & dates of a khal item', action = khalorg.edit_all },
  --       },
  --     }
  --   end,
  -- },
}

return spec
