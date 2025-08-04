-- local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local lspconfig = require("lspconfig")
local lsp_util = require("lspconfig/util")

local utils = require("core.utils")

vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
    },
    -- virtual_text = true,
    underline = true,
    update_in_insert = true,
    severity_sort = true,
})

local function on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    utils.load_mappings("lspconfig", { buffer = bufnr })

    if client.server_capabilities.signatureHelpProvider then
        require("nvchad.signature").setup(client)
    end

    if not utils.load_config().ui.lsp_semantic_tokens and client.supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "taplo", "omnisharp", "emmet_language_server", "hls" }

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup({
        on_attach = on_attach,
        capabilities = capabilities,
    })
end

-- TAPLO --
lspconfig["taplo"].setup({
    -- on_attach = on_attach,
    -- capabilities = capabilities,
    settings = {
        ["taplo"] = {
            format = true,
        },
    },
})

lspconfig.omnisharp.setup({
    --     on_attach = on_attach,
    --     capabilities = capabilities,
    -- settings = {
    -- omnisharp = {
    -- handlers = {
    --     ["textDocument/definition"] = function(err, result, ctx, config)
    --         return require("omnisharp_extended").handler(err, result, ctx, config)
    --     end,
    -- },
    -- keys = {
    --     {
    --         "gd",
    --         function()
    --             require("omnisharp_extended").telescope_lsp_definitions()
    --         end,
    --         desc = "Goto Definition",
    --     },
    -- },
    enable_editorconfig_support = true,
    enable_ms_build_load_projects_on_demand = false,
    enable_roslyn_analyzers = true,
    organize_imports_on_format = true,
    enable_import_completion = true,
    sdk_include_prereleases = true,
    analyze_open_documents_only = false,
    -- },
    -- },
})

--
-- lspconfig.pyright.setup { blabla}
