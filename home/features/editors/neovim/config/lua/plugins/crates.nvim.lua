--- A neovim plugin that helps managing crates.io dependencies

---@type LazyPluginSpec
local spec = {
  'saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  opts = {
    -- completion = {
    --   blink = { enabled = true },
    -- },
    completion = {
      crates = {
        enabled = true, -- disabled by default
        max_results = 10, -- The maximum number of search results to display
        min_chars = 3, -- The minimum number of charaters to type before completions begin appearing
      },
    },
    lsp = {
      enabled = true,
      -- on_attach = function(client, bufnr)
      --   -- the same on_attach function as for your other lsp's
      --   --
      --   vim.keymap.set('n', 'K', function()
      --     require('crates').show_popup()
      --   end)
      -- end,
      actions = true,
      completion = true,
      hover = true,
    },
  },
}

return spec
