---@type NvPluginSpec
local spec = {
    "nvimdev/lspsaga.nvim",
    event = { "VeryLazy" },
    keys = {
        { "gh", "<cmd> Lspsaga finder<cr>", desc = "Lspsaga finder" },
        { "gp", "<cmd> Lspsaga peek_definition<cr>", desc = "Lspsaga finder" },
        -- { "gl", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Show line diagnostics" },
        { "gl", "<cmd>lua vim.diagnostic.open_float(nil,{focus=false})<cr>", desc = "Show line diagnostics" },
        { "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Show line diagnostics" },
        -- { "gs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Documents symbols" },
        -- { "gS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
        { "g\\", "<cmd>Lspsaga outline<cr>", desc = "Symbols outline" },
        { "<leader>cS", "<cmd>Lspsaga outline<cr>", desc = "Symbols outline" },
        { "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Previous diagnostics" },
        { "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next diagnostics" },
        { "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next diagnostics" },
        { "<leader>ci", "<cmd>Lspsaga incoming_calls<cr>", desc = "Incoming calls" },
        { "<leader>co", "<cmd>Lspsaga outgoing_calls<cr>", desc = "Outgoing calls" },
    },
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "lspsaga")
        require("lspsaga").setup(opts)
    end,
    opts = {
        ui = {
            winblend = 15,
            expand = "",
            collapse = "",
            incoming = "󰏷 ",
            outgoing = "󰏻 ",
            lines = { "╰", "├", "│", "─", "╭" },
        },
        code_action = {
            show_server_name = true,
            extend_gitsigns = true,
        },
        lightbulb = {
            enable = false,
            sign = false,
            virtual_text = false,
        },
        scroll_preview = {
            scroll_down = "<C-f>",
            scroll_up = "<C-b>",
        },
        finder = {

            keys = {
                shuttle = "[w",
                toggle_or_open = "o",
                vsplit = "\\",
                split = "-",
                quit = "q",
                close = "<C-c>k",
            },
        },
        definition = {
            keys = {
                edit = "o",
                vsplit = "\\",
                split = "-",
                quit = "q",
                close = "<C-c>k",
            },
        },
        symbol_in_winbar = {
            enable = false,
        },
        outline = {
            auto_preview = false,
            detail = true,
            auto_close = true,
            close_after_jump = false,
            keys = {
                toggle_or_jump = "o",
                quit = "q",
                jump = "e",
            },
        },
        callhierarchy = {
            keys = {
                edit = "o",
                vsplit = "\\",
                split = "-",
                close = "<C-c>k",
                quit = "q",
                shuttle = "[w",
                toggle_or_req = "u",
            },
        },
    },
}

return spec
