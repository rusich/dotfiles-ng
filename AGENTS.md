# AGENTS.md - NixOS Dotfiles Repository Guide

This document provides guidelines for AI agents working with this NixOS dotfiles repository.

## Repository Overview

This is a NixOS configuration repository using flakes for system management. It contains configurations for multiple hosts (NixOS and Darwin/macOS) and uses home-manager for user configuration.

## Build Commands

### System Configuration
- **Build and switch to configuration for a specific host**: `sudo nixos-rebuild switch --flake .#<hostname>`
- **Build without switching**: `sudo nixos-rebuild build --flake .#<hostname>`
- **Test configuration (build and boot)**: `sudo nixos-rebuild test --flake .#<hostname>`
- **Dry-run (show what would be done)**: `sudo nixos-rebuild dry-build --flake .#<hostname>`
- **Build with debug info**: `sudo nixos-rebuild switch --flake .#<hostname> --show-trace`

### Home Manager Configuration
- **Apply home-manager configuration**: `home-manager switch --flake .#rusich`
- **Build home configuration**: `home-manager build --flake .#rusich`

### Flake Operations
- **Update flake inputs**: `nix flake update`
- **Check flake consistency**: `nix flake check`
- **List available configurations**: `nix flake show`
- **Build specific output**: `nix build .#<output>`

### Development & Testing
- **Enter development shell**: `nix develop`
- **Run nix evaluation**: `nix eval .#<attribute>`
- **Format Nix files**: `nix fmt` (if nixpkgs-fmt is available)
- **Check Nix syntax**: `nix-instantiate --parse <file.nix>`

## Linting & Formatting

### Nix Code Style
This repository follows standard Nix conventions:

1. **Indentation**: 2 spaces (no tabs)
2. **Line length**: No strict limit, but keep lines readable
3. **Function arguments**: Place on separate lines for multi-argument functions
4. **Attribute sets**: Use consistent spacing around `=` and `;`
5. **Imports**: List imports at top of file, one per line

### Formatting Tools
- **nixpkgs-fmt**: Recommended for formatting Nix code
- **alejandra**: Alternative Nix formatter (not currently configured)
- **statix**: Nix linter for common patterns (not currently configured)

To format all Nix files:
```bash
find . -name "*.nix" -type f -exec nixpkgs-fmt {} \;
```

## Code Style Guidelines

### File Structure
- **Module files**: Should be self-contained and focused on a single concern
- **Host configurations**: Located in `hosts/<os>/<hostname>/`
- **Common modules**: Located in `modules/<os>/common/` or `modules/<os>/<feature>/`
- **Overlays**: Located in `overlays/`
- **Custom packages**: Located in `pkgs/`

### Naming Conventions
- **Variables**: `camelCase` for local variables, `snake_case` for attribute names
- **Functions**: `camelCase`
- **Files**: `kebab-case.nix` for module files
- **Directories**: `kebab-case/`

### Import Patterns
```nix
# Standard import pattern for modules
{ config, lib, pkgs, ... }:

# With additional arguments
{ pkgs, lib, config, nixosModules, ... }:

# Function with let binding
{ pkgs, ... }:
let
  myPackage = pkgs.callPackage ./my-package.nix { };
in
{
  # configuration
}
```

### Attribute Set Style
```nix
# Multi-line attribute sets
{
  option1 = value1;
  option2 = value2;
  
  nested = {
    suboption1 = "value";
    suboption2 = 42;
  };
}

# Lists with with-pkgs pattern
environment.systemPackages = with pkgs; [
  git
  vim
  htop
];
```

### Error Handling
- Use `lib.mkIf`, `lib.mkDefault`, `lib.mkForce` for conditional options
- Use `assert` statements for validation in packages
- Use `throw` for unrecoverable errors in modules
- Use `builtins.trace` for debugging (remove before committing)

### Type Annotations
While Nix is dynamically typed, consider adding comments for complex types:
```nix
# type: { enable?: bool, package?: derivation }
{ config, lib, pkgs, ... }:
```

## Testing Guidelines

### Configuration Testing
1. **Always test builds**: Run `nixos-rebuild build` before switching
2. **Check evaluation**: Use `nix-instantiate` to validate syntax
3. **Test in VM**: For major changes, consider testing in a NixOS VM
4. **Generation management**: Keep old generations for rollback

### Module Testing
- Test modules in isolation: `nix eval -f module.nix`
- Check option definitions: Use `nixos-option` command
- Validate imports: Ensure all imported paths exist

## Best Practices

### 1. Module Design
- Keep modules focused and reusable
- Use conditionals (`lib.mkIf`) for optional features
- Provide sensible defaults with `lib.mkDefault`
- Document non-obvious options with comments

### 2. Package Management
- Prefer nixpkgs packages when available
- Use overlays for custom package versions
- Mark unfree packages with `allowUnfree = true` in specific contexts
- Use `callPackage` for custom packages

### 3. Host Configuration
- Keep host-specific configuration minimal
- Reuse common modules where possible
- Document hardware-specific patches
- Use conditionals for hardware detection

### 4. Flake Management
- Keep flake.nix clean and organized
- Use `follows` for input consistency
- Document special arguments in `specialArgs`
- Version pin important inputs

### 5. Security Considerations
- Never commit secrets or credentials
- Use age or sops-nix for secret management
- Review package sources and hashes
- Enable only necessary services

## Common Commands Reference

```bash
# System management
sudo nixos-rebuild switch --flake .#darkstar
sudo nixos-rebuild switch --flake .#matebook

# Home manager
home-manager switch --flake .#rusich

# Garbage collection
nix-collect-garbage -d
nix-store --optimise

# Debugging
nix why-depends /nix/store/<hash1> /nix/store/<hash2>
nix-store -q --references /nix/store/<hash>

# Profile management
nix profile list
nix profile remove <number>
```

## Troubleshooting

### Common Issues
1. **Evaluation errors**: Check Nix syntax with `nix-instantiate --parse`
2. **Build failures**: Use `--show-trace` for detailed error info
3. **Missing imports**: Verify file paths in import statements
4. **Option conflicts**: Check for duplicate definitions

### Debugging Tips
- Use `builtins.trace` for debugging (remove after)
- Check `nixos-option` for current option values
- Examine generation differences with `nvd diff`
- Use `nix-store --verify` for store corruption

## Notes for AI Agents

1. **Always test changes**: Never apply untested configuration changes
2. **Follow existing patterns**: Match the code style of surrounding files
3. **Keep commits focused**: One logical change per commit
4. **Document changes**: Update README.md if adding new features
5. **Respect the flake structure**: Don't modify flake.nix without understanding the implications

Remember: This is a system configuration repository. Changes can affect the entire operating system. Always proceed with caution and test thoroughly.