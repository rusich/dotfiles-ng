local spec = {
  'EdenEast/nightfox.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    options = {
      transparent = false,
      styles = {
        csmments = 'italic',
        keywords = 'bold',
        types = 'italic,bold',
      },
    },
  },
}

return spec
