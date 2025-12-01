-- For `plugins/markview.lua` users.
return {
  "OXY2DEV/markview.nvim",
  lazy = false,

  -- Completion for `blink.cmp`
  dependencies = { "saghen/blink.cmp" },
  keys = {
    { '<leader>um', "<cmd>Markview<cr>", desc = 'Toggle Markview render' },
  },
  opts = {
    -- latex = {
    --   enable = false,
    -- }
    --
    yaml = {
      properties = {
        ["^created$"] = {
          match_string = "^created$",
          use_types = false,
          text = "󰃭 ",
          hl = "MarkviewIcon3"
        },
        ["^updated$"] = {
          match_string = "^updated$",
          use_types = false,
          text = "󰃭 ",
          hl = "MarkviewIcon3"
        }

      },
    }
  }
};
