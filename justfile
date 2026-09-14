# NixOS / home-manager / nix-darwin task runner.
# Servers: `just install <configuration> <server>` then `just rebuild ...`.
# Bootstrap SSH first, e.g.:
#   ssh-copy-id -o PubkeyAuthentication=no -o PasswordAuthentication=yes \
#     -o PreferredAuthentications=password root@<server>

default:
    @just --list

# Install a host from scratch over SSH (nixos-anywhere + disko).
# WARNING: wipes the target disk; regenerates hosts/nixos/<configuration>/hardware-configuration.nix.
install configuration server:
    @printf '\033[1;31m'
    @printf 'WARNING: это ДЕПЛОЙ на сервер %s\n' 'root@{{server}}'
    @printf 'Конфигурация %s будет установлена С НУЛЯ (nixos-anywhere).\n' '{{configuration}}'
    @printf '\033[0m'
    @printf 'Вы уверены? Введите "yes" для продолжения: '; read -r answer; if [ "$answer" != "yes" ]; then echo "Отменено."; exit 1; fi
    nix run github:nix-community/nixos-anywhere -- \
        --flake ".#{{configuration}}" \
        --target-host root@{{server}} \
        --generate-hardware-config nixos-generate-config \
        ./hosts/nixos/{{configuration}}/hardware-configuration.nix

# Rebuild an already installed host remotely (system + integrated home-manager).
rebuild configuration server:
    nixos-rebuild switch --flake ".#{{configuration}}" --target-host root@{{server}}

# Rebuild a local NixOS host: argument targets .#<configuration>, default auto-detects (--flake .).
switch configuration="":
    if [ -n "{{configuration}}" ]; then \
        sudo nixos-rebuild switch --flake ".#{{configuration}}"; \
    else \
        sudo nixos-rebuild switch --flake .; \
    fi

# Apply home-manager for the current user@hostname (standalone).
home:
    home-manager switch --flake .

# Update flake inputs.
update:
    nix flake update

# Format all nix files.
fmt:
    nix fmt

# Check the flake.
check:
    nix flake check
