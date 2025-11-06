return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = true,
  event = "BufReadPre",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({})

    null_ls.register({
      name      = "my-source",
      method    = null_ls.methods.CODE_ACTION,
      filetypes = { "txt", "lua" },
      generator = {
        fn = function(params)
          local out = {}
          table.insert(out, {
            title = 'test',
            action = function()
              print('test')
            end
          })

          return out
        end,
      },
    })
  end
}
