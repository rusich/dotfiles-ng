-- Custom lsp servers setup (in ~/.config/nvim/after/lsp/)
vim.lsp.enable("nixd")
vim.lsp.enable("gdscript")
vim.lsp.enable("roslyn_ls")


vim.diagnostic.config {
  virtual_lines = {
    current_line = true,
  },
  virtual_text = false,
  severity_sort = true,
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
      [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
      [vim.diagnostic.severity.HINT] = 'DiagnosticHint',
    },
  },
}

-- Set keymaps when LSP client attached
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    -- Enable CodeLens
    local bufnr = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client:supports_method 'textDocument/codeLens' then
      vim.lsp.codelens.refresh()
      vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
        buffer = bufnr,
        callback = vim.lsp.codelens.refresh,
      })
    end

    -- Set LSP Keymaps
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    vim.keymap.set('n', 'grr', function()
      Snacks.picker.lsp_references()
    end, { buffer = event.buf, nowait = true, desc = 'LSP: ' .. 'References' })

    map('gri', function()
      Snacks.picker.lsp_implementations()
    end, 'Goto Implementation')

    map('gd', function()
      Snacks.picker.lsp_definitions()
    end, 'Goto Definition')

    map('gD', function()
      Snacks.picker.lsp_declarations()
    end, 'Goto Declaration')

    map('grt', function()
      Snacks.picker.lsp_type_definitions()
    end, 'Goto T[y]pe Definition')

    map('<leader>ss', function()
      Snacks.picker.lsp_symbols()
    end, 'LSP Symbols')

    map('<leader>sS', function()
      Snacks.picker.lsp_workspace_symbols()
    end, 'LSP Workspace Symbols')

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('<leader>cl', vim.lsp.codelens.run, '[C]ode [L]ens')

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  end,
})
