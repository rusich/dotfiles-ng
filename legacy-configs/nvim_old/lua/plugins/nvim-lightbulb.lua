-- The plugin shows a lightbulb in the sign column whenever a
-- textDocument/codeAction is available at the current cursor position.

---@type LazyPluginSpec
local spec = {
  'kosayoda/nvim-lightbulb',
  event = 'LspAttach',
  config = true,
  opts = {
    autocmd = { enabled = true },
    code_lenses = true,
  },
}

return spec
