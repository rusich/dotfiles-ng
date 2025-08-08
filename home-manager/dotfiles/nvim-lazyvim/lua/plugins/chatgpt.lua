-- Lazy
return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  opts = {
    api_key_cmd = "secret-tool lookup short PROXY_API_KEY",
    api_host_cmd = "secret-tool lookup short PROXY_API_URL",
    -- edit_with_instructions = {
    --   diff = true,
    -- },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>ac", "<cmd>ChatGPT<cr>", desc = "ChatGPT" },
    { "<leader>ad", "<cmd>ChatGPTRun docstring<cr>", desc = "ChatGPT Docstring", mode = { "n", "v" } },
    { "<leader>aE", "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
    { "<leader>ag", "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
    { "<leader>aT", "<cmd>ChatGPTRun translate<CR>", "Translate ru", mode = { "n", "v" } },
    { "<leader>ak", "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
    { "<leader>at", "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
    { "<leader>ao", "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
    { "<leader>as", "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
    { "<leader>ab", "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
    { "<leader>ae", "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
    { "<leader>ar", "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
    { "<leader>aa", "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
  },
}
