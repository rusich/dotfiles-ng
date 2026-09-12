-- A pretty diagnostics, references, telescope results, quickfix and
-- location list to help you solve all the trouble your code is causing.

local spec = {
  'folke/trouble.nvim',
  cmd = { 'Trouble' },
  opts = { use_diagnostic_signs = true },
  init = function()
    -- Automatically Open Trouble Quickfix
    vim.api.nvim_create_autocmd('QuickFixCmdPost', {
      callback = function()
        vim.cmd [[Trouble qflist open]]
      end,
    })

    -- TODO: Полная замена quickfix
    -- vim.api.nvim_create_autocmd('BufRead', {
    --   callback = function(ev)
    --     if vim.bo[ev.buf].buftype == 'quickfix' then
    --       vim.schedule(function()
    --         vim.cmd [[cclose]]
    --         vim.cmd [[Trouble qflist open]]
    --       end)
    --     end
    --   end,
    -- })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('trouble-lsp-attach', { clear = true }),
      callback = function(event)
        -- Replace `gO` with Trouble lsp_document_symbols
        vim.keymap.set(
          'n',
          'gO',
          '<cmd>Trouble lsp_document_symbols toggle win.position=right win.size=0.3 focus=true<cr>',
          { buffer = event.buf, desc = 'Trouble: Symbols' }
        )
      end,
    })
  end,
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics<cr>', desc = 'Diagnostics (Trouble)' },
    { '<leader>xq', '<cmd>Trouble quickfix<cr>', desc = 'Quickfix List (Trouble)' },
    { '<leader>xt', '<cmd>Trouble todo<cr>', desc = 'Todo List (Trouble)' },
    { '<leader>cs', '<cmd>Trouble lsp_document_symbols toggle win.position=right win.size=0.3 focus=true<cr>', desc = 'Symbols Panel (Trouble)' },
    {
      '[q',
      function()
        if require('trouble').is_open() then
          vim.cmd [[Trouble prev skip_groups= true jump=true ]]
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
          vim.cmd [[Trouble next skip_groups=true jump=true ]]
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
