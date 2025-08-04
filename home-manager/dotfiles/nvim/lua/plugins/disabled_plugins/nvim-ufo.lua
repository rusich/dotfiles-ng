IGNORED_FILETYPES = {
  'NvimTree',
  'dashboard',
  'nvcheatsheet',
  'dapui_watches',
  'dap-repl',
  'dapui_console',
  'dapui_stacks',
  'dapui_breakpoints',
  'dapui_scopes',
  'help',
  'vim',
  'alpha',
  'dashboard',
  'neo-tree',
  'Trouble',
  'noice',
  'lazy',
  'toggleterm',
  'nvdash',
  'neotest-summary',
  'sagaoutline',
  'dbui',
  'tsplayground',
}

local spec = {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },

  config = function()
    vim.o.foldcolumn = '1' -- '0' is not bad
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

    -- Option 3: treesitter as a main provider instead
    -- (Note: the `nvim-treesitter` plugin is *not* needed.)
    -- ufo uses the same query files for folding (queries/<lang>/folds.scm)
    -- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
    require('ufo').setup {
      provider_selector = function(bufnr, filetype, buftype)
        return { 'treesitter', 'indent' }
      end,
    }

    -- Save/Resotre folds between sessions
    vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
      pattern = { '*.*' },
      desc = 'save view (folds), when closing file',
      callback = function()
        vim.cmd 'set foldmethod=manual'
        vim.cmd 'mkview'
        -- vim.cmd 'set foldmethod=expr'
      end,
    })
    vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
      pattern = { '*.*' },
      desc = 'load view (folds), when opening file',
      callback = function()
        vim.cmd 'silent! loadview'
        vim.cmd 'set foldmethod=manual'
        -- vim.cmd 'set foldmethod=expr'
      end,
    })

    -- Disable fold sign
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('disable_fold_sign', { clear = true }),
      pattern = IGNORED_FILETYPES,
      callback = function(event)
        vim.cmd 'setlocal foldcolumn=0'
        -- if event.buf.buftype == "nofile" then
        --     print("WinEnter:")
        -- end
      end,
    })
  end,
}

return spec
