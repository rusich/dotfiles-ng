--- 🦀 Supercharge your Rust experience in Neovim! A heavily modified fork of rust-tools.nvim
local spec = {
  'mrcjkb/rustaceanvim',
  version = '^9', -- Recommended
  -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
  -- No need for lazy.nvim to lazy-load it.
  lazy = false, -- This plugin is already lazy
  ['rust-analyzer'] = {
    cargo = {
      allFeatures = true,
    },
  },
}

return spec
