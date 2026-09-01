---@type vim.lsp.Config
local vault = vim.fn.expand '~/Nextcloud/Notes' .. '/'

return {
  on_attach = function(client, bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= '' and vim.startswith(name, vault) then
      -- Внутри вольта completion/rename/references/definition полностью
      -- отдаём obsidian-ls, у marksman оставляем только диагностику
      -- битых/дублирующихся ссылок (и TOC code action).
      local caps = client.server_capabilities
      caps.completionProvider = nil
      caps.renameProvider = nil
      caps.referencesProvider = nil
      caps.definitionProvider = nil
      caps.declarationProvider = nil
    end
  end,
}
