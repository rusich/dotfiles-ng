-- luals.lua
return {
  cmd = { 'nixd', '--semantic-tokens=true' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
  settings = {
    nixd = {
      nixpkgs = {
        expr = 'import (builtins.getFlake(toString ./.)).inputs.nixpkgs { }',
        -- expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.default.options',
        -- expr = 'import <nixpkgs> { }',
      },
      formatting = {
        command = { 'nixfmt' },
      },
      options = {
        nixos_options = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.default.options',
        },
        nix_darwin_options = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).darwinConfigurations.default.options',
          -- expr = 'let flake = builtins.getFlake(toString ./.); in flake.darwinConfigurations.default.options',
        },
        home_manager_options = {
          -- expr = '(builtins.getFlake ("git+file://" + toString ./.)).legacyPackages.x86_64-linux.homeConfigurations.rusich.options',
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).legacyPackages.x86_64-linux.homeConfigurations.default.options',
          -- expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations.default.options',
        },
      },
    },
  },
}
