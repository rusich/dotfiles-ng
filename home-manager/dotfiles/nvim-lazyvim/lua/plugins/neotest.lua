local prefix = "<leader>t"
return {
  "nvim-neotest/neotest",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-neotest/neotest-plenary" },
    { "nvim-neotest/neotest-python" },
    { "nvim-treesitter/nvim-treesitter" },
    { "Issafalcon/neotest-dotnet" },
    { "rouge8/neotest-rust" },
    { "klen/nvim-test" },
  },

  opts = {
    adapters = {
      ["neotest-rust"] = {},
      ["neotest-dotnet"] = {
        dap = { justMyCode = false },
      },
      ["neotest-python"] = {},
    },
  },
  keys = {
    { prefix, desc = "󰙨 Testing" },
    { prefix .. "a", "<cmd>lua require('neotest').run.attach()<cr>", desc = "Attach" },
    { prefix .. "f", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "Run File" },
    {
      prefix .. "F",
      "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
      desc = "Debug File",
    },
    { prefix .. "l", "<cmd>lua require('neotest').run.run_last()<cr>", desc = "Run Last" },
    { prefix .. "L", "<cmd>lua require('neotest').run.run_last({ strategy = 'dap' })<cr>", desc = "Debug Last" },
    { prefix .. "r", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run Nearest" },
    { prefix .. "d", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = "Debug Nearest" },
    { prefix .. "o", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", desc = "Output" },
    { prefix .. "S", "<cmd>lua require('neotest').run.stop()<cr>", desc = "Stop" },
    { prefix .. "s", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "Summary" },
    { prefix .. "m", "<cmd>lua require('neotest').summary.run_marked()<cr>", desc = "Run marked" },
    { prefix .. "n", "<cmd>lua require('neotest').jump.next()<cr>", desc = "Jump Next" },
    { prefix .. "p", "<cmd>lua require('neotest').jump.prev()<cr>", desc = "Jump Previous" },
    { prefix .. "N", "<cmd>lua require('neotest').jump.next({status = 'failed'})<cr>", desc = "Jump Next FAILED" },
    {
      prefix .. "P",
      "<cmd>lua require('neotest').jump.prev({status = 'failed'})<cr>",
      desc = "Jump Previous FAILED",
    },
    { prefix .. "e", "<Plug>PlenaryTestFile", desc = "PlenaryTestFile" },
    { prefix .. "v", "<cmd>TestVisit<cr>", desc = "Visit" },
    { prefix .. "x", "<cmd>TestSuite<cr>", desc = "Suite" },
  },
}
