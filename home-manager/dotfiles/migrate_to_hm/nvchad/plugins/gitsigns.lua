---@type NvPluginSpec
local spec = {
    "lewis6991/gitsigns.nvim",
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "git")
        require("gitsigns").setup(opts)

        -- colors fix
        local isDarkTheme = vim.o.background == "dark"
        if isDarkTheme then
            vim.cmd([[highlight DiffAdd guifg=NONE guibg=#364144]])
            vim.cmd([[highlight DiffDelete guifg=NONE guibg=#443245]])
            vim.cmd([[highlight DiffChange guifg=NONE guibg=#25293d]])
            vim.cmd([[highlight DiffText guifg=NONE guibg=#366144]])
        else
            vim.cmd([[highlight DiffAdd guifg=NONE guibg=#dafdd3]])
            vim.cmd([[highlight DiffDelete guifg=NONE guibg=#fbe1e0]])
            vim.cmd([[highlight DiffChange guifg=NONE guibg=#e5effb]])
            vim.cmd([[highlight DiffText guifg=NONE guibg=#bdd8f5]])
        end
    end,
    keys = {
        {
            "]h",
            function()
                if vim.wo.diff then
                    return "]c"
                end
                vim.schedule(function()
                    require("gitsigns").next_hunk()
                end)
                return "<Ignore>"
            end,
            desc = "Next git hunk",
        },
        {
            "[h",
            function()
                if vim.wo.diff then
                    return "[c"
                end
                vim.schedule(function()
                    require("gitsigns").prev_hunk()
                end)
                return "<Ignore>"
            end,
            desc = "Prev git hunk",
        },
        { "<leader>gh", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage hunk" },
        { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "Undo stage hunk" },
        { "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", mode = { "n", "v" }, desc = "Reset hunk" },
        { "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview hunk" },
        { "<leader>gL", "<cmd>Gitsigns blame_line<CR>", desc = "Blame line" },
        { "<leader>gx", "<cmd>Gitsigns toggle_deleted<CR>", desc = "Toggle deleted" },
        { "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>", desc = "Stage buffer" },
        { "<leader>gR", "<cmd>Gitsigns reset_buffer<CR>", desc = "Reset buffer" },
        { "<leader>gD", "<cmd>Gitsigns diffthis<CR>", desc = "Diff this" },
        { "<leader>g~", "<cmd>Gitsigns diffthis ~<CR>", desc = "Diff this ~" },
        { "<leader>ub", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle line git blame" },
        { "ih", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x", "v" }, desc = "Select hunk" },
    },
}

return spec
