local capabilities = require("plugins.configs.lspconfig").capabilities

local function on_attach(client, bufnr)
    if client.server_capabilities.signatureHelpProvider then
        require("nvchad.signature").setup(client)
    end
end

---@type NvPluginSpec
local spec = {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    opts = function()
        local ok, mason_registry = pcall(require, "mason-registry")
        -- local adapter ---@type any
        -- if ok then
        --     -- rust tools configuration for debugging support
        --     local codelldb = mason_registry.get_package("codelldb")
        --     local extension_path = codelldb:get_install_path() .. "/extension/"
        --     local codelldb_path = extension_path .. "adapter/codelldb"
        --     local liblldb_path = ""
        --     if vim.loop.os_uname().sysname:find("Windows") then
        --         liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
        --     elseif vim.fn.has("mac") == 1 then
        --         liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
        --     else
        --         liblldb_path = extension_path .. "lldb/lib/liblldb.so"
        --     end
        --     adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
        -- end
        return {
            tools = {

                inlay_hints = {
                    auto = false,
                },
                on_initialized = function()
                    vim.cmd([[
                augroup RustLSP
                  autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
                  autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
                  autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
                augroup END
              ]])
                end,
            },
            server = {
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            runBuildScripts = true,
                        },
                        checkOnSave = {
                            allFeatures = true,
                            command = "clippy",
                            extraArgs = { "--no-deps" },
                        },
                        procMacro = {
                            enable = true,
                            ignored = {
                                ["async-trait"] = { "async_trait" },
                                ["napi-derive"] = { "napi" },
                                ["async-recursion"] = { "async_recursion" },
                            },
                        },
                    },
                },
                -- })
            },
        }
    end,
    -- config = true,
}

return spec
