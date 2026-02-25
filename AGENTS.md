# AGENTS.md - Nix Dotfiles Configuration Guide

This document provides guidelines for AI agents working with this Nix-based dotfiles repository.

## Repository Overview

This is a NixOS, nix-darwin, and home-manager configuration repository organized as a Nix flake. It manages system configurations, home configurations, and dotfiles across multiple hosts.

## Build Commands

### Flake Operations
```bash
# Build NixOS configuration for a specific host
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Build home-manager configuration
nix build .#homeConfigurations.rusich.activationPackage

# Apply NixOS configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Apply home-manager configuration
home-manager switch --flake .#rusich

# Update flake inputs
nix flake update

# Show available flake outputs
nix flake show
```

### Development Environment
```bash
# Enter development shell (if available)
nix develop

# Run nix evaluation checks
nix eval .#checks.<system> --apply builtins.attrNames
```

## Linting and Formatting

### Nix Code Style
```bash
# Format Nix files with nixpkgs-fmt (recommended)
nixpkgs-fmt **/*.nix

# Alternative: Use alejandra for formatting
# alejandra **/*.nix

# Check Nix syntax
nix-instantiate --parse --quiet <file.nix>

# Evaluate Nix expression
nix-instantiate --eval --strict <file.nix>
```

### Shell Scripts
```bash
# Format shell scripts with shfmt
shfmt -w -i 2 -ci **/*.sh

# Check shell scripts with shellcheck
shellcheck **/*.sh
```

## Testing

### Nix Evaluation Tests
```bash
# Test flake evaluation
nix flake check

# Test specific NixOS configuration
nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel.drvPath

# Test home-manager configuration
nix eval .#homeConfigurations.rusich.activationPackage.drvPath
```

### Module Testing
```bash
# Test individual modules
nix eval -f modules/home/<module>/default.nix

# Test with specific attributes
nix-instantiate --eval modules/home/<module>/default.nix -A config
```

## Code Style Guidelines

### Nix Language Conventions

#### Imports and Structure
- Use attribute set destructuring in function arguments: `{ config, pkgs, ... }:`
- Place imports at the top of files after function arguments
- Use `let...in` blocks for local definitions before the main attribute set
- Follow Nixpkgs module pattern: return attribute sets, not functions

#### Formatting
- Use 2-space indentation (consistent with nixpkgs-fmt)
- No trailing whitespace
- Maximum line length: 80 characters (soft limit)
- Use double quotes for strings unless interpolation is needed
- Align equals signs in attribute sets when it improves readability

#### Naming Conventions
- Use `camelCase` for attribute names and variables
- Use `kebab-case` for file names and directory names
- Use descriptive names: `enableFeature` not `feat`
- Boolean attributes should start with `enable`, `allow`, `use`, or `with`

#### Attribute Sets
- Use recursive attribute sets (`rec { }`) sparingly and only when necessary
- Group related attributes together
- Place required attributes before optional ones
- Use `lib.mkDefault`, `lib.mkIf`, `lib.mkMerge` for conditional configuration

#### Error Handling
- Use `assert` statements for precondition checks
- Use `lib.throwIf` for validation with error messages
- Provide helpful error messages with context

### Module Organization

#### File Structure
```
modules/
├── nixos/          # NixOS system modules
│   ├── common/     # Common NixOS configuration
│   └── <feature>/  # Feature-specific modules
├── home/           # home-manager modules
│   ├── <app>/      # Application configuration
│   └── shell.nix   # Shell configuration
└── darwin/         # nix-darwin modules
```

#### Module Patterns
```nix
# Standard module pattern
{ config, pkgs, lib, ... }:

{
  options = {
    # Define module options here
    myFeature.enable = lib.mkEnableOption "my feature";
  };

  config = lib.mkIf config.myFeature.enable {
    # Configuration enabled when feature is enabled
    environment.systemPackages = with pkgs; [ myPackage ];
  };
}
```

### Import Guidelines
- Use absolute paths within the repository: `"${./relative/path}"`
- Reference other modules using specialArgs: `"${homeModules}/<module>"`
- Use `imports` for module composition
- Avoid circular dependencies between modules

### Package Management
- Use `pkgs.callPackage` for custom packages
- Reference overlays from `overlays/default.nix`
- Use `with pkgs;` for package lists when appropriate
- Prefer stable packages (`nixpkgs-stable`) unless specific features needed

### Host Configuration
- Host-specific configs go in `hosts/<os>/<hostname>/`
- Common configurations go in `modules/<os>/common/`
- Hardware-specific configs in `hardware-configuration.nix`
- Use `specialArgs` to pass user configuration and module paths

## Git Workflow

### Commit Messages
- Use present tense imperative: "Add feature" not "Added feature"
- First line: short summary (50 chars max)
- Blank line
- Detailed description (72 chars per line)
- Reference issues or related commits

### Branch Strategy
- `main`: stable configurations
- Feature branches for experimental changes
- Test changes on VM configurations first

## Best Practices

### Safety
1. Always test configurations on a VM or separate system first
2. Keep backups of critical configurations
3. Use versioned inputs for reproducibility
4. Document breaking changes in commit messages

### Performance
1. Use `lib.mkIf` to conditionally include configurations
2. Avoid importing large attribute sets unnecessarily
3. Use `builtins.readDir` for dynamic host discovery
4. Cache evaluation results with `nix eval --store`

### Maintainability
1. Keep modules focused and single-purpose
2. Document non-obvious configuration choices
3. Use consistent naming across modules
4. Reference upstream documentation when available

## Troubleshooting

### Common Issues
- **Evaluation errors**: Run `nix-instantiate --parse --eval` to debug
- **Build failures**: Check `nix log /nix/store/<hash>`
- **Configuration issues**: Use `nixos-rebuild build-vm` to test in VM

### Debug Commands
```bash
# Show derivation dependencies
nix-store -q --references $(nix eval .#<output>.drvPath --raw)

# Check evaluation trace
nix-instantiate --trace-verbose --show-trace <file.nix>

# Profile evaluation
nix eval --profile /tmp/nix-profile .#<output>
```

## Agent Instructions

When working with this repository:
1. Always test Nix evaluations before applying changes
2. Follow existing patterns in similar modules
3. Use the formatting tools before committing
4. Update documentation when adding new features
5. Consider cross-platform compatibility (Linux/Darwin)

Remember: This is a system configuration repository - changes can affect the user's entire system. Be cautious and test thoroughly.
