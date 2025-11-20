-- local mocha_palette = {
-- }
local darken = function(hex, amount)
  return require('catppuccin.utils.colors').darken(hex, amount)
end
local lighten = function()
  return require('catppuccin.utils.colors').lighten
end

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    flavour = 'frappe',
    -- flavour = 'mocha',
    -- flavour = 'macchiato',
    transparent_background = false,
    term_colors = true,
    color_overrides = {
      frappe = {
        rosewater = '#f5e0dc',
        flamingo = '#f2cdcd',
        pink = '#f5c2e7',
        mauve = '#cba6f7',
        red = '#f38ba8',
        maroon = '#eba0ac',
        peach = '#fab387',
        yellow = '#f9e2af',
        green = '#a6e3a1',
        teal = '#94e2d5',
        sky = '#89dceb',
        sapphire = '#74c7ec',
        blue = '#89b4fa',
        lavender = '#b4befe',
        text = '#cdd6f4',
        subtext1 = '#bac2de',
        subtext0 = '#a6adc8',
        overlay2 = '#9399b2',
        overlay1 = '#7f849c',
        overlay0 = '#6c7086',
        surface2 = '#585b70',
        surface1 = '#45475a',
        surface0 = '#313244',
        base = '#15181D',
        mantle = '#0A1214',
        crust = '#040b04',
        -- crust = '#ff0000', -- splitter?
      },
      mocha = {},
    },
    -- All flavours. For per-flavour override use highlight_overrides
    custom_highlights = function(colors)
      return {
        -- folds
        Folded = { fg = '#7f849c', bg = '#1b1d27' },
        -- lsp_renamer
        RenamerBorder = { fg = colors.red },
        RenamerTitle = { fg = colors.base, bold = true, bg = colors.red },
        -- general
        -- ['NormalFloat'] = { bg = colors.mantle, blend = config.ui.winblend },
        -- ['FloatBorder'] = { fg = colors.surface2, bg = colors.base },
        ['PmenuSel'] = { fg = colors.crust, bg = colors.green },
        -- orgmode
        ['@org.headline.level1'] = { link = 'Statement' },
        ['@org.headline.level2'] = { link = 'Special' },
        ['@org.headline.level3'] = { link = 'Type' },
        ['@org.headline.level4'] = { link = 'Identifier' },
        ['@org.headline.level5'] = { link = 'String' },
        ['@org.headline.level6'] = { link = 'Constant' },
        ['@org.headline.level7'] = { link = 'Title' },
        ['@org.headline.level8'] = { link = 'PreProc' },
        -- hl('@org.timestamp.active', { fg = colors.teal, bold = true })
        ['@org.timestamp.inactive'] = { link = 'Comment' },
        ['@org.properties'] = { fg = colors.surface2 },
        ['@org.drawer'] = { link = '@org.properties' },
        ['@org.plan'] = { fg = colors.overlay0 },
        ['@org.directive'] = { fg = colors.teal, bold = true },
        ['@org.table.heading'] = { link = 'RenderMarkdownTableRow' },
        ['Quote'] = { fg = colors.red, bg = colors.mantle },
        ['@markup.link.url'] = { fg = colors.peach, underline = true, bold = true },
        -- hl('@org.hyperlink', { fg = colors.peach, underline = true, bold = true })
        -- render-markdown
        ['RenderMarkdownH1'] = { fg = colors.red },
        ['RenderMarkdownH2'] = { fg = colors.peach },
        ['RenderMarkdownH3'] = { fg = colors.yellow },
        ['RenderMarkdownH4'] = { fg = colors.green },
        ['RenderMarkdownH5'] = { fg = colors.blue },
        ['RenderMarkdownH6'] = { fg = colors.mauve },
        -- bg
        ['RenderMarkdownH1Bg'] = { bg = darken(colors.red, 0.2) },
        ['RenderMarkdownH2Bg'] = { bg = darken(colors.peach, 0.2) },
        ['RenderMarkdownH3Bg'] = { bg = darken(colors.yellow, 0.2) },
        ['RenderMarkdownH4Bg'] = { bg = darken(colors.green, 0.2) },
        ['RenderMarkdownH5Bg'] = { bg = darken(colors.blue, 0.2) },
        ['RenderMarkdownH6Bg'] = { bg = darken(colors.mauve, 0.2) },
        -- variant two
        -- ['RenderMarkdownH1Bg']= { fg = colors.mantle, bg = darken(colors.red, 0.2) },
        -- ['RenderMarkdownH2Bg']= { fg = colors.mantle, bg = darken(colors.peach, 0.2) },
        -- ['RenderMarkdownH3Bg']= { fg = colors.mantle, bg = darken(colors.yellow, 0.2) },
        -- ['RenderMarkdownH4Bg']= { fg = colors.mantle, bg = darken(colors.green, 0.2) },
        -- ['RenderMarkdownH5Bg']= { fg = colors.mantle, bg = darken(colors.blue, 0.2) },
        -- hl('RenderMarkdownH6Bg', { fg = colors.mantle, bg = darken(colors.mauve, 0.2) })
        ['RenderMarkdownCode'] = { bg = colors.mantle },
        ['RenderMarkdownCodeInline'] = { bg = colors.mantle },
        ['RenderMarkdownDash'] = { bg = colors.red },
      }
    end,
    dim_inactive = {
      enabled = false, -- dims the background color of inactive window
      shade = 'dark',
      percentage = 0.30, -- percentage of the shade to apply to the inactive window
    },
    default_integrations = true,
    integrations = {
      barbecue = {
        dim_dirname = true, -- directory name is dimmed by default
        bold_basename = true,
        dim_context = false,
        alt_background = false,
      },
      snacks = true,
      mason = true,
      fidget = true,
      which_key = true,
      render_markdown = true,
      mini = {
        enabled = true,
        indentscope_color = 'red', -- catppuccin color (eg. `lavender`) Default: text
      },
      blink_cmp = true,
      diffview = true,
      headlines = true,
      dropbar = true,
      neogit = true,
      lsp_trouble = true,
      telescope = {
        enabled = true,
        style = 'nvchad',
      },
      dadbod_ui = true,
    },
  },
}
