local null_ls = require("null-ls")

local b = null_ls.builtins

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local opts = {
    sources = {

        -- webdev stuff
        b.formatting.deno_fmt,                                                     -- choosed deno for ts/js files cuz its very fast!
        b.formatting.prettier.with({ filetypes = { "html", "markdown", "css" } }), -- so prettier works only on these filetypes
        b.diagnostics.eslint_d,
        b.code_actions.eslint_d,
        b.formatting.eslint_d,
        b.formatting.taplo,
        b.formatting.fourmolu,

        -- Lua
        b.formatting.stylua,

        -- cpp
        b.formatting.clang_format,
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end
    end,
}

null_ls.setup(opts)
