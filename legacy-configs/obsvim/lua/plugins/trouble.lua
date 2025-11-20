-- A pretty diagnostics, references, telescope results, quickfix and
-- location list to help you solve all the trouble your code is causing.

---@type LazyPluginSpec
local spec = {
  'folke/trouble.nvim',
  cmd = { 'Trouble' },
  opts = { use_diagnostic_signs = true },
  event = 'VeryLazy',
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics<cr>', desc = 'Diagnostics (Trouble)' },
    { '<leader>xq', '<cmd>Trouble quickfix<cr>', desc = 'Quickfix List (Trouble)' },
    { '<leader>xt', '<cmd>Trouble todo<cr>', desc = 'Todo List (Trouble)' },
    { '<C-\\>', '<cmd>Trouble lsp_document_symbols toggle win.position=right win.size=0.3 focus=true<cr>', desc = 'Toggle LSP symbols (Trouble)' },
    {
      '[q',
      function()
        if require('trouble').is_open() then
          require('trouble').prev { skip_groups = true, jump = true }
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = 'Previous trouble/quickfix item',
    },
    {
      ']q',
      function()
        if require('trouble').is_open() then
          require('trouble').next { skip_groups = true, jump = true }
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = 'Next trouble/quickfix item',
    },
  },
}

return spec
