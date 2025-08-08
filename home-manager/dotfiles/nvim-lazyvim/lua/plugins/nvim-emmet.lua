return {
  "olrtg/nvim-emmet",
  config = function()
    vim.keymap.set({ "n", "v" }, "<C-e>", require("nvim-emmet").wrap_with_abbreviation)
  end,
}
