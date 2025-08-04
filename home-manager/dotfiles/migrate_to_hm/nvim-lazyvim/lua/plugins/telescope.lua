local actions = require("telescope.actions")
return {
    "nvim-telescope/telescope.nvim",
    keys = {
        -- add a keymap to browse plugin files
        -- stylua: ignore
        {
            "<leader>flF",
            function() require("telescope.builtin").find_files({ cwd = "~/.config/lazyvim/data/nvim/lazy/" }) end,
            desc = "Find Plugin File",
        },
        {
            "<leader>flW",
            function()
                require("telescope.builtin").live_grep({ cwd = "~/.config/lazyvim/config/nvim/" })
            end,
            desc = "Grep Plugin Files",
        },
        {
            "<leader>flf",
            function() require("telescope.builtin").find_files({ cwd = "~/.config/lazyvim/config/nvim/" }) end,
            desc = "Find Config File",
        },
        {
            "<leader>flw",
            function()
                require("telescope.builtin").live_grep({ cwd = "~/.config/lazyvim/data/nvim/lazy/" })
            end,
            desc = "Grep Config Files",
        },
        {
            "<leader>faf",
            function()
                require("telescope.builtin").find_files({ cwd = "~/.config/astronvim/config/" })
            end,
            desc = "Find Astronvim File",
        },
        {
            "<leader>faw",
            function()
                require("telescope.builtin").live_grep({ cwd = "~/.config/astronvim/config/" })
            end,
            desc = "Grep AstroNvim Files",
        },
        {
            "<leader>fw",
            function()
                require("telescope.builtin").live_grep({ cwd = "~/.config/nvim/" })
            end,
            desc = "Grep Config Files",
        },
    },
    -- change some options
    opts = {
        defaults = {
            mappings = {
                i = {
                    ["<C-n>"] = actions.cycle_history_next,
                    ["<C-p>"] = actions.cycle_history_prev,
                    ["<C-j>"] = actions.move_selection_next,
                    ["<C-k>"] = actions.move_selection_previous,
                },
            },
        },
    },
}
