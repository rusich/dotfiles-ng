return {
  "rcarriga/nvim-dap-ui",
  -- stylua: ignore
  keys = {
    { "<leader>de", function() require("dapui").eval(nil, { enter = true }) end, desc = "Eval (F2)", mode = {"n", "v"} },
    { "<F2>", function() require("dapui").eval(nil, { enter = true }) end, desc = "Eval", mode = {"n", "v"} },

  },
  opts = {},
}
