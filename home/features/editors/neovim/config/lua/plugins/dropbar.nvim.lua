-- IDE-like breadcrumbs, out of the box

---@type LazyPluginSpec
local specs = {
  'Bekaboo/dropbar.nvim',
  lazy = true,
  event = 'LspAttach',
  -- optional, but required for fuzzy finder support
  -- dependencies = {
  --   'nvim-telescope/telescope-fzf-native.nvim',
  --   build = 'make',
  -- },
  keys = {
    {
      '<leader>;',
      function()
        require('dropbar.api').pick()
      end,
      desc = 'Pick symbols in winbar',
    },
    {
      '[;',
      function()
        require('dropbar.api').goto_context_start()
      end,
      desc = 'Go to start of current context',
    },
    {
      '];',
      function()
        require('dropbar.api').select_next_context()
      end,
      desc = 'Select next context',
    },
  },
}

return specs
