-- Highlight, list and search todo comments in your projects

---@type LazyPluginSpec
local spec = {
  -- Highlight todo, notes, etc in comments
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = { signs = true },
}

return spec
-- vim: ts=2 sts=2 sw=2 et
