# NixOS Configuration

Мой набор конфигураций для NixOS, nix-darwin и home-manager, использующий flakes.

## Структура проекта

```
.
├── flake.nix          # inputs + outputs (тонкий, логика сборки тут же)
├── flake.lock         # Зависимости flakes
├── hosts/             # Конфигурации хостов (авто-обнаруживаются по папкам)
│   ├── nixos/         # NixOS: darkstar, matebook, MacBook-Air
│   └── darwin/        # nix-darwin (macOS): macos-sonoma-vm
├── home/              # home-manager слой
│   ├── common/        # Безусловная база для всех (shell, git, xdg, CLI)
│   ├── features/      # Опциональные фичи (options.features.*.enable)
│   │   ├── editors/ cli/ desktop/ gui/ pim/ dev/ opencode/
│   ├── presets/       # Наборы фич по классу машины
│   │   ├── shared.nix # Кроссплатформенные фичи (desktop + darwin)
│   │   ├── desktop.nix# Linux-десктоп (импортит shared)
│   │   ├── darwin.nix # macOS (импортит shared)
│   │   └── server.nix # Минимальный сервер (без shared)
│   └── users/         # Пользователи: home/users/<user>/{user,common,<host>}.nix
├── modules/           # Переиспользуемые системные модули
│   ├── common/        # Общее для NixOS, darwin и home-manager
│   ├── nixos/         # NixOS-модули (авто-импорт: my.nixosModules.*)
│   └── darwin/        # nix-darwin модули
├── templates/         # Шаблоны (server/…)
├── overlays/          # Кастомные overlays
└── pkgs/              # Кастомные пакеты
```

## Как это устроено

- **Хосты** обнаруживаются по папкам `hosts/nixos/<host>` и `hosts/darwin/<host>`.
- **Пользователи и их машины** — по файлам `home/users/<user>/<host>.nix`;
  ключ `user@host` появляется в `homeConfigurations` автоматически.
- **Фичи** включаются через `features.<group>.<name>.enable = true` в
  `home/presets/*` или в `home/users/<user>/<host>.nix`.
- **Десктопы/macOS** используют standalone home-manager; **серверы** (в будущем) —
  home-manager как NixOS-модуль (тот же файл `home/users/<user>/<host>.nix`).

## Первоначальная настройка на новой системе NixOS

### 1. Включение экспериментальных функций flakes

```nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

Или через переменную окружения:

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
```

### 2. Клонирование репозитория

```bash
git clone https://github.com/rusich/dotfiles-ng.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. Установка конфигурации

```bash
# NixOS
sudo nixos-rebuild switch --flake .#darkstar

# home-manager (standalone, авто-детект user@hostname)
home-manager switch --flake .
# или явно:
home-manager switch --flake .#rusich@darkstar

# macOS (nix-darwin)
darwin-rebuild switch --flake .#macos-sonoma-vm
```

### 4. Обновление

```bash
nix flake update                 # обновить inputs
sudo nixos-rebuild switch --flake .#<host>
home-manager switch --flake .    # применить home-изменения
```

### 5. Управление поколениями

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --rollback
```

## Форматирование

Канонический форматтер — `nixfmt` (RFC-стиль), заведён как `formatter` во флейке:

```bash
nix fmt          # отформатировать все .nix файлы
```

Редактор (nixd) настроен форматировать им при сохранении.

## Входы (inputs)

- `nixpkgs-stable` — `nixos-26.05` (он же `nixpkgs`)
- `nixpkgs-unstable` — `nixos-unstable`
- `home-manager` — `release-26.05`
- `nix-darwin` — `nix-darwin-26.05`
- `nixos-hardware`, `musnix`, `firefox-addons`, `millennium`

Версия релиза указана в трёх input-ах; flake-схема требует строковых
литералов в `url`, поэтому вынести её в переменную нельзя — менять синхронно.

## Как добавлять

### Пользователя (home-manager)

1. `home/users/<user>/user.nix` — identity: `username`, `fullName`, `email`
   (при необходимости `sshKeys` для NixOS-хостов).
2. `home/users/<user>/<host>.nix` — `imports = [ ./common.nix ];`
   (или `+ ../../presets/desktop.nix`, если нужен Linux-десктоп).
3. (опционально) `home/users/<user>/common.nix` — выбор фич
   (`user.cli.*`, `user.gui.*`, `user.pim.*`, ...), общий для всех машин юзера.
4. Флейк сам создаст ключ `homeConfigurations."<user>@<host>"`.
   Применение на машине: `home-manager switch --flake .#<user>@<host>`.
   Фичи с `mkOutOfStoreSymlink` (neovim/kitty/niri/rofi/keepassxc/noctalia/opencode)
   требуют локальный клон репозитория у пользователя (`~/.dotfiles`).

### Хост (NixOS)

1. `hosts/nixos/<host>/configuration.nix` + `hardware-configuration.nix`.
2. Включить профили/сервисы: `nixos.profiles.desktop.enable = true;`,
   `nixos.services.podman.enable = true;` и т.д.
3. `sudo nixos-rebuild switch --flake .#<host>`.

### Сервер (минимальный home-manager)

1. Скопировать `templates/server/configuration.nix` в
   `hosts/nixos/<server>/configuration.nix`, рядом положить
   `hardware-configuration.nix`.
2. Создать `home/users/rusich/<server>.nix`:
   `{ ... }: { imports = [ ./common.nix ../../presets/server.nix ]; }`.
3. Оставить в конфиге хоста `nixos.home-manager.integrated.enable = true;` —
   тогда HM развернётся вместе с системой (`home-manager-rusich.service`).
4. С десктопа: `nixos-rebuild switch --flake .#<server> --target-host root@<server>`.
   SSH-ключи `rusich`/`root` уже заданы в `home/users/rusich/user.nix`.

### Опции: где что искать

- **Система**: `nixos.profiles.*`, `nixos.services.*`, `nixos.hardware.*`,
  `nixos.virtualisation.*`, `nixos.home-manager.integrated.enable`.
- **Пользователь**: `user.<группа>.<имя>.enable` — группы `editors`, `cli`,
  `desktop`, `gui`, `pim`, `dev`, `opencode`.

## Устранение неполадок

```bash
nix-collect-garbage -d                                      # кэш
nix flake check                                             # зависимости
sudo nixos-rebuild switch --flake .#<host> --show-trace     # отладка сборки
```
