-- local gpt_model = "gpt-3.5-turbo-1106" -- proxyapi
-- local gpt_model = "gpt-4-0613" -- slow
-- local gpt_max_tokens = 4096 -- gpt-4-0613
local gpt_model = "gpt-3.5-turbo-16k-0613" -- GOOD and FAST
local gpt_max_tokens = 2048                -- gpt-3.5.turbo-16k-0613

-- Lazy
---@type NvPluginSpec
local spec = {
    event = "VeryLazy",
    "jackMort/ChatGPT.nvim",
    opts = {
        api_key_cmd = "secret-tool lookup short PROXY_API_KEY",
        -- api_host_cmd = "secret-tool lookup short PROXY_API_URL",
        api_host_cmd = "secret-tool lookup short GPT4_FREE_URL",

        openai_params = {
            model = gpt_model,
            frequency_penalty = 0,
            presence_penalty = 0,
            max_tokens = gpt_max_tokens,
            temperature = 0,
            top_p = 1,
            n = 1,
        },
        openai_edit_params = {
            model = gpt_model,
            frequency_penalty = 0,
            presence_penalty = 0,
            max_tokens = gpt_max_tokens,
            temperature = 0,
            top_p = 1,
            n = 1,
        },
        -- edit_with_instructions = {
        --   diff = true,
        -- },
        --

        -- popup_window = {
        --     border = {
        --         highlight = "TelescopePreviewBorder",
        --     },
        --     win_options = {
        --         winhighlight = "Normal:TelescopePreviewNormal,FloatBorder:FloatBorder",
        --     },
        -- },
        -- system_window = {
        --     border = {
        --         highlight = "TelescopePromptBorder",
        --     },
        --     win_options = {
        --         winhighlight = "Normal:TelescopePromptNormal,FloatBorder:FloatBorder",
        --     },
        -- },
        -- popup_input = {
        --     border = {
        --         highlight = "TelescopePromptBorder",
        --     },
        --     win_options = {
        --         winhighlight = "Normal:TelescopePromptNormal,FloatBorder:FloatBorder",
        --     },
        -- },
        -- settings_window = {
        --     win_options = {
        --         winhighlight = "Normal:TelescopePromptNormal,FloatBorder:FloatBorder",
        --     },
        -- },
    },
    dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    keys = {
        { "<leader>ac", "<cmd>ChatGPT<cr>",                       desc = "ChatGPT" },
        { "<leader>ad", "<cmd>ChatGPTRun docstring<cr>",          desc = "ChatGPT Docstring", mode = { "n", "v" } },
        { "<leader>aE", "<cmd>ChatGPTEditWithInstruction<CR>",    "Edit with instruction",    mode = { "n", "v" } },
        { "<leader>ag", "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction",       mode = { "n", "v" } },
        { "<leader>aT", "<cmd>ChatGPTRun translate<CR>",          "Translate ru",             mode = { "n", "v" } },
        { "<leader>ak", "<cmd>ChatGPTRun keywords<CR>",           "Keywords",                 mode = { "n", "v" } },
        { "<leader>at", "<cmd>ChatGPTRun add_tests<CR>",          "Add Tests",                mode = { "n", "v" } },
        { "<leader>ao", "<cmd>ChatGPTRun optimize_code<CR>",      "Optimize Code",            mode = { "n", "v" } },
        { "<leader>as", "<cmd>ChatGPTRun summarize<CR>",          "Summarize",                mode = { "n", "v" } },
        { "<leader>ab", "<cmd>ChatGPTRun fix_bugs<CR>",           "Fix Bugs",                 mode = { "n", "v" } },
        { "<leader>ae", "<cmd>ChatGPTRun explain_code<CR>",       "Explain Code",             mode = { "n", "v" } },
        { "<leader>ar", "<cmd>ChatGPTRun roxygen_edit<CR>",       "Roxygen Edit",             mode = { "n", "v" } },
        {
            "<leader>aa",
            "<cmd>ChatGPTRun code_readability_analysis<CR>",
            "Code Readability Analysis",
            mode = { "n", "v" },
        },
    },
}

return spec
