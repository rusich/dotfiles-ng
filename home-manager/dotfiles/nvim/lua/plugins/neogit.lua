-- An interactive and powerful Git interface for Neovim, inspired by Magit
-- + DivvView

---@type LazyPluginSpec
local spec = {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration
      -- Only one of these is needed.
      -- 'nvim-telescope/telescope.nvim', -- optional
    },
    config = true,

    keys = {
      {
        '<leader>gg',
        '<cmd>Neogit<cr>',
        desc = 'Open Neogit',
      },
      {
        '<leader>gc',
        '<cmd>Neogit commit<cr>',
        desc = 'Git commit',
      },
      {
        '<leader>gp',
        '<cmd>Neogit pull<cr>',
        desc = 'Git pull',
      },
      {
        '<leader>gP',
        '<cmd>Neogit push<cr>',
        desc = 'Git push',
      },
      {
        '<leader>gb',
        '<cmd>Telescope git_branches<cr>',
        desc = 'Git branches',
      },
    },
  },
}

return spec
