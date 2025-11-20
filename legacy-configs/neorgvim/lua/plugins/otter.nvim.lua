return {
  'jmbuhr/otter.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    buffers = {
      diagnostic_update_events = { "BufWritePost" },
      set_filetype = true,
      write_to_disk = true
    }
  },

  keys = {
    { '<leader>co', '<cmd>lua require("otter").activate()<cr>', desc = 'Toggle otter' },
  }
}
