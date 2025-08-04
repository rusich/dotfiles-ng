---@type NvPluginSpec
local spec = {
    {
        "williamboman/mason.nvim",
        -- event = "VeryLazy",
        opts = {
            automatic_installation = true,
            ensure_installed = {
                -- linters, formatters here
                "prettier",
                "eslint_d",
                "stylua",
                "fourmolu",
            },
        },
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        config = function()
            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = {
                    -- lsp servers
                    "lua_ls",

                    -- web dev stuff
                    -- "css-lsp",
                    -- "html-lsp",
                    -- "typescript-language-server",
                    -- "deno",

                    -- -- c/cpp stuff
                    -- "clangd",
                    -- "clang-format",

                    -- -- rust stuff
                    -- "rust-analyzer",
                    -- "taplo",
                },
            })
        end,
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        ft = { "cs", "rust", "haskell" },
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_installation = true,
            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = {
                "coreclr",
                "codelldb",
                "haskell",
                -- Update this to ensure that you have the debuggers for the langs you want
            },

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            -- handlers = {},
            handlers = {
                function(config)
                    -- all sources with no handler get passed here

                    -- Keep original functionality
                    require("mason-nvim-dap").default_setup(config)
                end,
                coreclr = function(config)
                    local dap = require("dap")

                    dap.configurations.cs = {
                        {
                            type = "coreclr",
                            name = "NetCoreDbg: Launch My",
                            request = "launch",
                            program = function()
                                local build_cmd = "dotnet build -c Debug"
                                print("> " .. build_cmd)

                                -- local output = vim.fn.system(build_cmd)
                                vim.fn.system(build_cmd)

                                if vim.v.shell_error == 1 then
                                    vim.notify("Build failed!", vim.log.levels.ERROR)
                                    vim.cmd("TermExec direction=horizontal size=30 cmd='dotnet build -c Debug' ")
                                    return ""
                                end
                                vim.notify("Build success!")
                                return "${workspaceFolder}/bin/Debug/net8.0/${workspaceFolderBasename}.dll"
                            end,
                            -- stopOnEntry = false,
                        },
                    }
                    dap.adapters.coreclr = {
                        type = "executable",
                        command = vim.fn.exepath("netcoredbg"),
                        args = { "--interpreter=vscode" },
                    }

                    -- require("mason-nvim-dap").default_setup(config)
                end,

                codelldb = function(config)
                    local dap = require("dap")
                    dap.configurations.rust = {
                        {
                            name = "Rust debug",
                            type = "codelldb",
                            request = "launch",
                            program = function()
                                local build_cmd = "cargo build"
                                print("> " .. build_cmd)

                                output = vim.fn.system(build_cmd)

                                if vim.v.shell_error == 1 then
                                    vim.notify("Build failed!", vim.log.levels.ERROR)
                                    -- require("dapui").close()
                                    vim.cmd("TermExec direction=horizontal size=30 cmd='cargo_build' ")
                                    return ""
                                end
                                vim.notify("Build success!")
                                return "${workspaceFolder}/target/debug/${workspaceFolderBasename}"
                            end,
                            cwd = "${workspaceFolder}",
                            stopOnEntry = false,
                        },
                    }

                    dap.adapters.codelldb = {
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = vim.fn.exepath("codelldb"),
                            args = { "--port", "${port}" },
                        },
                    }
                    -- require("mason-nvim-dap").default_setup(config)
                end,
            },
        },
    },
}

return spec
