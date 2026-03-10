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
      default = { 'snippets', 'lsp', 'path', 'buffer' },
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

        draw = {
          columns = { { 'kind_icon' }, { 'label', 'label_description', 'source_name', gap = 1 } },
        },
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
