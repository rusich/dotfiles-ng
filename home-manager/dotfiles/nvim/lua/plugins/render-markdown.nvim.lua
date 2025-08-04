--- Plugin to improve viewing Markdown files in Neovim

---@type LazyPluginSpec
local spec = {
  'MeanderingProgrammer/render-markdown.nvim',
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  -- ft = { 'markdown', 'markdown-inline' },
  ft = { 'markdown', 'Avante', 'markdown-inline' },
  opts = {
    -- file_types = { 'markdown', 'markdown-inline' },
    file_types = { 'markdown', 'markdown-inline', 'Avante', 'codecompanion' },
    code = {
      enabled = true,
      border = 'thick',
      width = 'block',
      left_pad = 1,
      right_pad = 2,
    },
    heading = {
      border = false,
      -- position = 'inline',
    },
  },
}

return spec
