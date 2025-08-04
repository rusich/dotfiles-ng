local ignored_filetyes = {
    "NvimTree",
    "dashboard",
    "nvcheatsheet",
    "dapui_watches",
    "dap-repl",
    "dapui_console",
    "dapui_stacks",
    "dapui_breakpoints",
    "dapui_scopes",
    "help",
    "vim",
    "alpha",
    "dashboard",
    "neo-tree",
    "Trouble",
    "noice",
    "lazy",
    "toggleterm",
    "nvdash",
    "neotest-summary",
    "sagaoutline",
}

---@type NvPluginSpec
local spec = {
    {
        "kevinhwang91/nvim-ufo",
        event = "VimEnter",
        init = function()
            -- vim.o.foldcolumn = "auto"
            vim.o.foldlevel = 99 -- Using ufo provider need a large value
            vim.o.foldlevelstart = 99
            vim.o.foldnestmax = 0
            vim.o.foldenable = true
            vim.o.foldmethod = "manual"

            vim.opt.fillchars = {
                fold = " ",
                foldopen = "",
                foldsep = " ",
                foldclose = "",
                stl = " ",
                eob = " ",
            }

            -- Disable fold sign
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("nvchad_" .. "disable_fold_sign", { clear = true }),
                pattern = ignored_filetyes,
                callback = function(event)
                    vim.cmd("setlocal foldcolumn=0")
                    -- if event.buf.buftype == "nofile" then
                    --     print("WinEnter:")
                    -- end
                end,
            })
        end,
        dependencies = {
            "kevinhwang91/promise-async",
            {
                "luukvbaal/statuscol.nvim",
                opts = function()
                    local builtin = require("statuscol.builtin")
                    return {
                        relculright = true,
                        bt_ignore = { "nvdash", "nofile", "prompt", "terminal", "packer" },
                        ft_ignore = ignored_filetyes,
                        segments = {
                            -- Segment: Add padding
                            {
                                text = { "" },
                            },
                            -- Segment: Fold Column
                            {
                                text = { builtin.foldfunc },
                                click = "v:lua.ScFa",
                                maxwidth = 1,
                                colwidth = 1,
                                auto = false,
                            },
                            -- Segment: Add padding
                            {
                                text = { "" },
                            },
                            -- Segment : Show signs with one character width
                            {
                                sign = {
                                    name = { ".*" },
                                    maxwidth = 1,
                                    colwidth = 1,
                                },
                                auto = true,
                                click = "v:lua.ScSa",
                            },
                            -- Segment: Show line number
                            {
                                text = { "", "", builtin.lnumfunc, "" },
                                click = "v:lua.ScLa",
                                condition = { true, builtin.not_empty },
                            },
                            -- Segment: GitSigns exclusive
                            {
                                sign = {
                                    namespace = { "gitsign.*" },
                                    maxwidth = 1,
                                    colwidth = 1,
                                    auto = false,
                                },
                                click = "v:lua.ScSa",
                            },
                            -- Segment: Add padding
                            {
                                text = { "" },
                                hl = "Normal",
                                condition = { true, builtin.not_empty },
                            },
                        },
                    }
                end,
            },
        },
        opts = {
            close_fold_kinds_for_ft = { "imports" },
            provider_selector = function()
                return { "treesitter", "indent" }
            end,
        },
    },
}

return spec
