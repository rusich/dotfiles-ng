-- Custom lsp servers setup (in ~/.config/nvim/after/lsp/)
vim.lsp.enable("nixd")
vim.lsp.enable("gdscript")

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
    -- Сочетания клавиш заменяют стадартные для Neovim 0.11
    -- Для более удобной навигации через Snacks.picker
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    local is_omnisharp = client and client.name == 'omnisharp'


    map('gri', function()
      Snacks.picker.lsp_implementations()
    end, 'Goto Implementation')

    -- УСЛОВНОЕ НАЗНАЧЕНИЕ ДЛЯ OMNISHARP
    if is_omnisharp then
      -- Для OmniSharp используем расширенные функции
      map('gd', function()
        require('omnisharp_extended').lsp_definition()
      end, "Go to Definition (OmniSharp)")
      -- map('grt', function()
      --   require('omnisharp_extended').lsp_type_definition()
      -- end, "Go to Type Definition (OmniSharp)")
      -- map('grr', function()
      --   require('omnisharp_extended').lsp_references()
      -- end, "Go to References (OmniSharp)")
      -- map('gri', function()
      --   require('omnisharp_extended').lsp_implementation()
      -- end, "Go to Implementation (OmniSharp)")
    else
      -- Для других LSP используем стандартные функции
      map('gd', function()
        Snacks.picker.lsp_definitions()
      end, 'Goto Definition')
    end


    map('grt', function()
      Snacks.picker.lsp_type_definitions()
    end, 'Goto Type Definition')

    vim.keymap.set('n', 'grr', function()
      Snacks.picker.lsp_references()
    end, { buffer = event.buf, nowait = true, desc = 'LSP: ' .. 'References' })

    map('gri', function()
      Snacks.picker.lsp_implementations()
    end, 'Goto Implementation')

    map('gD', function()
      Snacks.picker.lsp_declarations()
    end, 'Goto Declaration')


    map('<leader>ss', function()
      Snacks.picker.lsp_symbols()
    end, 'LSP Symbols')

    map('<leader>sS', function()
      Snacks.picker.lsp_workspace_symbols()
    end, 'LSP Workspace Symbols')

    map('<leader>cl', vim.lsp.codelens.run, '[C]ode [L]ens')
  end,
})
