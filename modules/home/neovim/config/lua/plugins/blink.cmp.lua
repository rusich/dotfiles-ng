local spec = {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'saghen/blink.compat',
  },
  version = '*',
  ---@module 'blink.cmp'
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
      },
      -- default = { 'snippets', 'lsp', 'path', 'buffer' },
      default = { 'snippets', 'buffer', 'lsp', 'path' },
      per_filetype = {
        lua = { 'lazydev', 'snippets', 'lsp', 'path', 'buffer' },
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
