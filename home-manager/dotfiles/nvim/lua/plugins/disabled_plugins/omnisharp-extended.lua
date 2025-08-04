-- Extended 'textDocument/definition' handler for OmniSharp Neovim LSP
-- (now also `textDocument/references`, `textDocument/implementation` and
-- source generated files)

---@type LazyPluginSpec
local spec = {
  'Hoffs/omnisharp-extended-lsp.nvim',
  lazy = true,
}

return spec
