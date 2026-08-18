return {
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    opts = function()
      local library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      }
      -- add all lazy plugins so their `---@type` annotations resolve
      for name in pairs(require('lazy.core.config').spec.plugins) do
        library[#library + 1] = name
      end
      return { library = library }
    end,
  },
  { -- optional blink completion source for require statements and module annotations
    'saghen/blink.cmp',
    opts = {
      sources = {
        -- add lazydev to your completion providers
        per_filetype = {
          lua = { 'lazydev', 'snippets', 'lsp', 'path', 'buffer' },
        },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
      },
    },
  },
}
