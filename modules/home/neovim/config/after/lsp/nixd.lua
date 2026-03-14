-- luals.lua
return {
  cmd = { 'nixd', '--semantic-tokens=true' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
  on_attach = function(client)
    -- client.server_capabilities.codeActionProvider = false
    -- client.server_capabilities.definitionProvider = false
    -- client.server_capabilities.definitionProvider = false
    -- client.server_capabilities.hoverProvider = false
    -- client.server_capabilities.referencesProvider = false
    -- client.server_capabilities.renameProvider = false
    -- client.server_capabilities.signatureProvider = false
    -- client.server_capabilities.completionProvider = true
  end,
  settings = {
    nixd = {
      nixpkgs = {
        -- expr = 'import (builtins.getFlake(toString ./.)).inputs.nixpkgs { }',
        expr = 'import <nixpkgs> { }',
      },
      formatting = {
        command = { 'nixfmt' },
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.darkstar.options',
        },
        -- outputs.legacyPackages.x86_64-linux.homeConfigurations.rusich
        home_manager = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).legacyPackages.x86_64-linux.homeConfigurations.rusich.options',
        },
        darwin = {
          expr = 'let flake = builtins.getFlake(toString ./.); in flake.darwinConfigurations.macos-sonoma-vm.options',
        },
      },
    },
  },
}
