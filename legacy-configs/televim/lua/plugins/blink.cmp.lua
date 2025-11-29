---@type LazyPluginSpec
local spec = {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'folke/lazydev.nvim',
    'saghen/blink.compat',
  },
  version = '*',
  -- version = '0.10',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- snippets = { preset = 'mini_snippets' },
    snippets = { preset = 'default' },
    keymap = { preset = 'default' },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },

    sources = {
      -- min_keyword_length = function()
      --   return vim.bo.filetype == 'org' and 3 or 0
      -- end,
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        org_roam = {
          name = 'org_roam', -- IMPORTANT: use the same name as you would for nvim-cmp
          module = 'blink.compat.source',

          -- all blink.cmp source config options work as normal:
          score_offset = -3,

          -- this table is passed directly to the proxied completion source
          -- as the `option` field in nvim-cmp's source config
          --
          -- this is NOT the same as the opts in a plugin's lazy.nvim spec
          opts = {
            -- this is an option from cmp-digraphs
            -- cache_digraphs_on_start = true,
          },
        },
        orgmode = {
          name = 'orgmode',
          -- module = 'blink.compat.source',
          module = 'orgmode.org.autocompletion.blink',
          fallbacks = { 'buffer' },
          -- score_offset = -3,
        },
        avante_commands = {
          name = 'avante_commands',
          module = 'blink.compat.source',
          score_offset = -3,
        },
        avante_mentions = {
          name = 'avante_mentions',
          module = 'blink.compat.source',
          score_offset = -3,
        },

        avante_files = {
          name = 'avante_files',
          module = 'blink.compat.source',
          score_offset = -3,
        },
      },
      -- default = { 'snippets', 'lsp', 'path', 'buffer' },
      default = { 'snippets', 'buffer', 'lsp', 'path' },
      per_filetype = {
        lua = { 'lazydev', 'snippets', 'lsp', 'path', 'buffer' },
        org = { 'org_roam', 'orgmode', 'snippets', 'path' },
        -- ['org-roam-select'] = {},
        codecompanion = { 'codecompanion' },
        AvanteInput = { 'lsp', 'avante_commands', 'avante_mentions', 'avante_files', 'path' },
      },
    },

    completion = {
      accept = { auto_brackets = { enabled = false } },
      documentation = {
        -- auto_show = true, auto_show_delay_ms = 1500 },
        window = {
          winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
        },
      },
      menu = {
        winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
      },
    },
    signature = {
      enabled = true,
      window = {
        winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder',
      },
    },
  },
  opts_extend = { 'sources.default' },
}

return spec
