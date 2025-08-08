return {
  "stevearc/aerial.nvim",
  event = "LazyFile",
  keys = { { "g\\", "<cmd>AerialToggle<cr>", desc = "Document symbols (Aerial)" } },
  opts = {
    layout = {
      resize_to_content = false,

      width = 0.2,
    },
    guides = {
      last_item = "╰╴",
    },
  },
}
