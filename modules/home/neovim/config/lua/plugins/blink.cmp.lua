local spec = {
  'saghen/blink.cmp',
  dependencies = {
    { 'rafamadriz/friendly-snippets', lazy = true },
    -- 'saghen/blink.compat',
  },
  version = '*',
  lazy = true,
  event = 'InsertEnter',
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
      providers = {
        snippets = {
          opts = {
            friendly_snippets = true, -- default

            -- see the list of frameworks in: https://github.com/rafamadriz/friendly-snippets/tree/main/snippets/frameworks
            -- and search for possible languages in: https://github.com/rafamadriz/friendly-snippets/blob/main/package.json
            -- the following is just an example, you should only enable the frameworks that you use
            extended_filetypes = {
              markdown = { 'jekyll' },
              sh = { 'shelldoc' },
              php = { 'phpdoc' },
              cpp = { 'unreal' },
              rust = { 'rustdoc' },
            },
          },
        },
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
