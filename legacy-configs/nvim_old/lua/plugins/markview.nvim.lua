-- For `plugins/markview.lua` users.
return {
  "OXY2DEV/markview.nvim",
  lazy = true,
  ft = { "markdown", "markdown_inline" },

  -- Completion for `blink.cmp`
  dependencies = { "saghen/blink.cmp" },
  keys = {
    { '<leader>um', "<cmd>Markview<cr>", desc = 'Toggle Markview render' },
  },
  opts = {
    latex = {
      -- using Snacks.nvim
      enable = false,
    },
    markdown = {
      list_items = {
        --   enable = false, -- Using checkmate.nvim for checkbox render

        marker_minus = {
          text = "-",
        },
      },
    },
    markdown_inline = {
      -- -- Using checkmate.nvim for checkbox render
      --   checkboxes = {
      --     enable = false
      --   }
    },

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
        },
        ["^hubs$"] = {
          match_string = "^hubs$",
          use_types = false,
          text = "⟗ ",
          hl = "MarkviewIcon3"
        },
        ["^urls$"] = {
          match_string = "^urls$",
          use_types = false,
          text = " ",
          hl = "MarkviewIcon3"
        }
      },
    }
  }
};
