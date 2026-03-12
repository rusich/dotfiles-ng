---@type vim.lsp.Config
return {
  cmd = {
    vim.fn.executable 'OmniSharp' == 1 and 'OmniSharp' or 'omnisharp',
    '-z', -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
    '--hostPID',
    tostring(vim.fn.getpid()),
    'DotNet:enablePackageRestore=true',
    '--encoding',
    'utf-8',
    '--loglevel',
    'trace',
    '--languageserver',
  },
  handlers = {
    ['textDocument/definition'] = function(...)
      return require('omnisharp_extended').handler(...)
    end,
  },
  capabilities = {
    workspace = {
      workspaceFolders = false, -- https://github.com/OmniSharp/omnisharp-roslyn/issues/909
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
}
