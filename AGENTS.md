# Agent Guidelines for Dotfiles Repository

## Build/Test/Lint Commands
- **Nix formatting**: `nixfmt-rfc-style` (installed in packages)
- **Lua formatting**: `stylua` with config in `nvim/.stylua.toml`
- **Build systems**: Use Nix flakes - `nix build` or `nixos-rebuild switch`

## Code Style Guidelines
- **Nix files**: Use RFC-style formatting (nixfmt-rfc-style)
- **Lua files**: 2-space indentation, 160 column width, single quotes preferred
- **Imports**: Group by type (nixpkgs, home-manager, custom modules)
- **Naming**: snake_case for variables, camelCase for functions
- **Error handling**: Use `lib` functions for Nix error checking

## Repository Structure
- NixOS configs in `nixos/hosts/` per machine
- Home Manager configs in `home-manager/`
- Dotfiles in `home-manager/dotfiles/` organized by application
- Common settings in `common/` directory

## Development
- Use Nix flakes for reproducible builds
- Follow Nixpkgs conventions for package management
- Test changes with `nixos-rebuild test` before switching