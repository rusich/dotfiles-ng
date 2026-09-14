# NixOS / home-manager / nix-darwin task runner.
# Servers: `just install <configuration> <server>` then `just rebuild ...`.
# The <server> is a host/IP WITHOUT a user (root@ is added automatically).
# Bootstrap SSH first (copy your key so nixos-anywhere needs no password):
#   ssh-copy-id -o PubkeyAuthentication=no -o PasswordAuthentication=yes \
#     -o PreferredAuthentications=password root@<server>
default:
    @just --list

# Install a host from scratch over SSH (nixos-anywhere + disko).
# WARNING: wipes the target disk; regenerates hosts/nixos/<configuration>/hardware-configuration.nix.
install configuration server:
    #!/usr/bin/env bash
    set -euo pipefail

    red='\033[1;91m'
    yellow='\033[1;93m'
    reset='\033[0m'

    banner() {
        printf '%b' "$1"
        printf '  !!!!!!  В Н И М А Н И Е  !!!!!!\n'
        printf '  УСТАНОВКА (nixos-anywhere) НА СЕРВЕР %s\n' 'root@{{server}}'
        printf '\n'
        printf '  ВСЕ ДАННЫЕ НА СЕРВЕРЕ БУДУТ УНИЧТОЖЕНЫ БЕЗВОЗВРАТНО!\n'
        printf '  Диск будет разбит и отформатирован заново (disko).\n'
        printf '\n'
        printf '  Конфигурация: %s\n' '{{configuration}}'
        printf '%b' "$reset"
    }

    for _ in 1 2 3 4 5; do
        banner "$red"
        sleep 0.3
        printf '\033[7A'
        banner "$yellow"
        sleep 0.3
        printf '\033[7A'
    done
    banner "$red"
    printf '\n'
    printf 'Введите "yes" ЦЕЛИКОМ, чтобы уничтожить и переустановить: '
    read -r answer
    if [ "$answer" != "yes" ]; then echo "Отменено."; exit 1; fi

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
