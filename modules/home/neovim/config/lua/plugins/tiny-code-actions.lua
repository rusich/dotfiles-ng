return {
  'rachartier/tiny-code-action.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    {
      'folke/snacks.nvim',
      opts = {
        terminal = {},
      },
    },
  },
  event = 'LspAttach',
  keys = {
    {
      '<A-.>',
      "<cmd>lua require('tiny-code-action').code_action()<cr>",
      mode = { 'n', 'v', 'x' },
      desc = 'Code Actions (Preview)',
      noremap = true,
      silent = true,
    },
  },
  opts = {
    backend = 'vim',
    -- backend = 'delta',
    picker = {
      -- 'select',
      -- 'snacks',
      'buffer',
      opts = {
        auto_preview = false,
      },
    },
    backend_opts = {
      delta = {
        -- Header from delta can be quite large.
        -- You can remove them by setting this to the number of lines to remove
        header_lines_to_remove = 4,

        -- The arguments to pass to delta
        -- If you have a custom configuration file, you can set the path to it like so:
        -- args = {
        --     "--config" .. os.getenv("HOME") .. "/.config/delta/config.yml",
        -- }
        args = {
          '--line-numbers',
        },
      },
    },
  },
}
