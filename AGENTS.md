# Agent Guidelines for NixOS Configuration Repository

This document provides guidelines for AI agents working with this NixOS configuration repository.

## Repository Overview

This is a NixOS, nix-darwin, and home-manager configuration repository using flakes. The structure includes:
- `hosts/` - Host-specific configurations (NixOS and Darwin/macOS)
- `modules/` - Reusable modules for NixOS and home-manager
- `overlays/` - Custom package overlays
- `pkgs/` - Custom package definitions

## Build Commands

### System Configuration
```bash
# Build and switch to configuration for a specific host
sudo nixos-rebuild switch --flake .#<hostname>

# Examples:
sudo nixos-rebuild switch --flake .#darkstar
sudo nixos-rebuild switch --flake .#matebook
sudo nixos-rebuild switch --flake .#nixos-vm

# Build without switching (dry-run)
sudo nixos-rebuild build --flake .#<hostname>

# Test configuration in a VM
sudo nixos-rebuild build-vm --flake .#<hostname>
```

### Home Manager Configuration
```bash
# Apply home-manager configuration
home-manager switch --flake .#rusich
```

### Flake Management
```bash
# Update all flake inputs
nix flake update

# Check flake for errors
nix flake check

# Show flake outputs
nix flake show
```

### Development and Testing
```bash
# Enter development shell with nix tools
nix develop

# Run nix evaluation check
nix eval --raw .#checks.x86_64-linux.build

# Format Nix files (using nixfmt-rfc-style)
nixfmt-rfc-style <file.nix>

# Lint Nix files (using nixd/nil LSP)
# Configured in Neovim via nixd package
```

## Linting and Formatting

### Nix Code Style
- **Indentation**: 2 spaces for Nix files (`.nix`)
- **Formatting**: Use `nixfmt-rfc-style` (RFC 0146 style)
- **Line length**: No explicit limit, but prefer readability
- **Imports**: Group imports at top of file, alphabetical order preferred

### Editor Configuration
The repository includes `.editorconfig` with:
- `*.nix`: 2 space indentation
- `*.sh`: 2 space indentation, LF line endings
- `Makefile`: Tab indentation
- General: Space indentation (not tabs)

### LSP Configuration
- **nixd**: Primary LSP for Nix development
- **nil**: Alternative LSP available
- Configured in Neovim via `modules/home/neovim/default.nix`

## Code Style Guidelines

### Nix Language Conventions

#### Function Definitions
```nix
# Single argument, simple function
{ arg1, arg2 }: {
  # body
}

# Multiple arguments with destructuring
{ lib, pkgs, config, ... }: {
  # body
}

# Let bindings for complex expressions
let
  inherit (pkgs) somePackage;
  customValue = lib.mkDefault "default";
in {
  # body
}
```

#### Attribute Sets
```nix
# Simple attribute set
{
  foo = "bar";
  baz = 42;
}

# Nested with consistent indentation
{
  networking = {
    hostName = "darkstar";
    networkmanager.enable = true;
  };
  
  services = {
    openssh.enable = true;
    xserver.enable = true;
  };
}
```

#### Imports and Modules
```nix
# Import paths should be relative or use specialArgs
imports = [
  ./hardware-configuration.nix
  "${nixosModules}/desktopCommon"
  "${nixosModules}/gaming.nix"
];

# Module definitions should follow NixOS module system
{ config, lib, pkgs, ... }: {
  options = {
    # Option definitions
  };
  
  config = {
    # Configuration
  };
}
```

### Naming Conventions
- **Variables**: `camelCase` for local variables
- **Attributes**: `camelCase` for nested attributes
- **Packages**: Use package names as defined in nixpkgs
- **Hostnames**: Lowercase, descriptive (e.g., `darkstar`, `matebook`)

### Error Handling
- Use `lib.mkDefault` for optional settings with defaults
- Use `lib.mkIf` for conditional configurations
- Use `assert` statements for validation where appropriate
- Prefer `throw` with descriptive messages for fatal errors

### Comments and Documentation
- Use `#` for single-line comments
- Multi-line comments with `/* */` for block comments
- Document non-obvious configurations and workarounds
- Include TODO comments with context: `# TODO: Reason for TODO`

## Module Structure

### NixOS Modules
Located in `modules/nixos/`:
- `common/` - Shared configurations for all NixOS systems
- `desktopCommon/` - Desktop-specific shared configurations
- Feature-specific modules (e.g., `gaming.nix`, `DAW.nix`)

### Home Manager Modules
Located in `modules/home/`:
- Application configurations (e.g., `kitty/`, `neovim/`)
- Shell configurations (e.g., `fish.nix`, `bash.nix`)
- Utility configurations (e.g., `git.nix`, `xdg.nix`)

### Module Patterns
```nix
# Typical module structure
{ config, lib, pkgs, ... }: {
  options = {
    # Module options
  };
  
  imports = [
    # Sub-modules
  ];
  
  config = lib.mkIf config.<module>.enable {
    # Conditional configuration
  };
}
```

## Host Configuration

### NixOS Hosts
Located in `hosts/nixos/<hostname>/`:
- `configuration.nix` - Main host configuration
- `hardware-configuration.nix` - Hardware-specific settings (auto-generated)

### Darwin Hosts
Located in `hosts/darwin/<hostname>/`:
- `configuration.nix` - macOS configuration using nix-darwin

## Package Management

### Custom Packages
- Defined in `pkgs/` directory
- Use `callPackage` pattern for dependencies
- Follow nixpkgs conventions for package definitions

### Overlays
- Defined in `overlays/default.nix`
- Used to modify or extend nixpkgs packages
- Applied globally in flake configuration

## Testing and Validation

### Before Committing
1. Run `nix flake check` to validate flake structure
2. Test build for affected hosts: `sudo nixos-rebuild build --flake .#<hostname>`
3. Apply formatting with `nixfmt-rfc-style`
4. Verify no evaluation errors with `nix eval`

### Common Issues to Check
- Missing dependencies in custom packages
- Incorrect attribute paths in configurations
- Module import paths (relative vs absolute)
- Flake input compatibility

## Security Considerations
- Never commit secrets or sensitive data
- Use `allowUnfree = true` only for necessary proprietary software
- Review third-party overlays and inputs for security
- Keep flake inputs updated to latest compatible versions

## Performance Tips
- Use `lib.mkDefault` for optional settings to avoid evaluation overhead
- Group related configurations in modules
- Avoid excessive recursion in Nix expressions
- Use `builtins.readDir` and `attrNames` for dynamic module imports

## Agent-Specific Notes

### For AI Agents (like opencode):
- Focus on Nix language patterns and module system
- Follow existing code style and structure
- Test changes with appropriate build commands
- Document non-trivial changes with comments
- Respect the flake-based architecture

### When Adding New Features:
1. Create appropriate module in `modules/` directory
2. Add imports to relevant host configurations
3. Test with `nixos-rebuild build`
4. Update documentation if needed

### When Modifying Existing Code:
1. Check similar patterns in other modules
2. Maintain backward compatibility where possible
3. Update all affected host configurations
4. Test on multiple systems if applicable