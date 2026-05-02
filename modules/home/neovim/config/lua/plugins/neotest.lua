-- An extensible framework for interacting with tests within NeoVim.

local prefix = '<leader>t'

---@type LazyPluginSpec
local spec = {
  'nvim-neotest/neotest',
  -- ft = { "rust", "python", "cs" },
  dependencies = {
    { 'nvim-neotest/nvim-nio', lazy = true },
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-treesitter/nvim-treesitter' },
    { 'nvim-neotest/neotest-python' },
    { 'MisanthropicBit/neotest-busted', lazy = true }, -- lua
    -- { 'HiPhish/neotest-busted' }, -- lua
    -- { 'rouge8/neotest-rust' },
    -- { 'klen/nvim-test' },
    -- { 'Issafalcon/neotest-dotnet' },
    -- { 'nvim-neotest/neotest-plenary' }, -- lua
  },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('neotest').setup {
      adapters = {
        -- -- ['neotest-dotnet'] = {},
        -- require 'neotest-rust',
        require 'rustaceanvim.neotest',
        require 'neotest-python' {
          dap = { justMyCode = false },
          args = { '--log-level', 'DEBUG' },
          runner = 'pytest',
        },
        require 'neotest-busted' {
          local_luarocks_only = false,
          -- busted_command = '/home/rusich/tmp/busted',
          -- minimal_init = 'spec/minimal_init.lua',
        },
      },
      status = { virtual_text = true },
      output = { open_on_run = false },
      quickfix = {
        enabled = true,
        open = false,
      },
      diagnostic = {
        enabled = true,
      },
    }
  end,
  keys = {
    { prefix, desc = 'Testing' },
    { prefix .. 'a', "<cmd>lua require('neotest').run.attach()<cr>", desc = 'Attach' },
    { prefix .. 'f', "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = 'Run File' },
    {
      prefix .. 'F',
      "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
      desc = 'Debug File',
    },
    { prefix .. 'l', "<cmd>lua require('neotest').run.run_last()<cr>", desc = 'Run Last' },
    { prefix .. 'L', "<cmd>lua require('neotest').run.run_last({ strategy = 'dap' })<cr>", desc = 'Debug Last' },
    { prefix .. 'r', "<cmd>lua require('neotest').run.run()<cr>", desc = 'Run Nearest' },
    { prefix .. 'd', "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = 'Debug Nearest' },
    { prefix .. 'o', "<cmd>lua require('neotest').output.open({ enter = true })<cr>", desc = 'Output' },
    { prefix .. 'S', "<cmd>lua require('neotest').run.stop()<cr>", desc = 'Stop' },
    { prefix .. 's', "<cmd>lua require('neotest').summary.toggle()<cr>", desc = 'Summary' },
    { prefix .. 'm', "<cmd>lua require('neotest').summary.run_marked()<cr>", desc = 'Run marked' },
    { ']t', "<cmd>lua require('neotest').jump.next()<cr>", desc = 'Jump to next TEST' },
    { '[t', "<cmd>lua require('neotest').jump.prev()<cr>", desc = 'Jump to previous TEST' },
    {
      ']T',
      "<cmd>lua require('neotest').jump.next({status = 'failed'})<cr>",
      desc = 'Jump Next FAILED TEST',
    },
    {
      '[T',
      "<cmd>lua require('neotest').jump.prev({status = 'failed'})<cr>",
      desc = 'Jump Previous FAILED TEST',
    },
    { prefix .. 'e', '<Plug>PlenaryTestFile', desc = 'PlenaryTestFile' },
    { prefix .. 'v', '<cmd>TestVisit<cr>', desc = 'Visit' },
    { prefix .. 'x', '<cmd>TestSuite<cr>', desc = 'Suite' },
  },
}

return spec
