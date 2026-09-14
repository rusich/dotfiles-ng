# NixOS Configuration

Мой набор конфигураций для NixOS, nix-darwin и home-manager, использующий flakes.

## Структура проекта

```
.
├── flake.nix          # inputs + outputs (тонкий, логика сборки тут же)
├── flake.lock         # Зависимости flakes
├── justfile           # just-рецепты: deploy/rebuild/switch/home/update/fmt/check
├── hosts/             # Конфигурации хостов (авто-обнаруживаются по папкам)
│   ├── nixos/         # NixOS: darkstar, matebook, MacBook-Air, generic-server
│   │   └── <host>/    # configuration.nix (+ disko.nix у серверов)
│   └── darwin/        # nix-darwin (macOS): macos-sonoma-vm
├── home/              # home-manager слой
│   ├── common/        # Безусловная база для всех (shell, git, xdg, CLI)
│   ├── features/      # Опциональные фичи (options.user.*.enable)
│   │   ├── editors/ cli/ desktop/ gui/ pim/ dev/ opencode/
│   │   └── bundles/   # meta-фичи: graphical, linux-desktop
│   └── users/         # Пользователи: home/users/<user>/{user,home,<host>}.nix
├── modules/           # Переиспользуемые системные модули
│   ├── common/        # Общее для NixOS, darwin и home-manager
│   ├── nixos/         # NixOS-модули
│   └── darwin/        # nix-darwin модули
├── templates/         # Шаблоны (server/…)
├── overlays/          # Кастомные overlays
└── pkgs/              # Кастомные пакеты
```

## Как это устроено

- **Хосты** обнаруживаются по папкам `hosts/nixos/<host>` и `hosts/darwin/<host>`.
- **Пользователи и их машины** — по файлам `home/users/<user>/<host>.nix`;
  ключ `user@host` появляется в `homeConfigurations` автоматически.
- **Фичи** включаются через `user.<group>.<name>.enable = true` в
  `home/users/<user>/<host>.nix` (листья) или одним флагом через
  `user.bundle.{graphical,linux-desktop}.enable` (наборы-«meta-фичи»).
- **Десктопы/macOS** используют standalone home-manager; **серверы** —
  home-manager как NixOS-модуль (тот же файл `home/users/<user>/<host>.nix`).
- **Серверный профиль** `nixos.profiles.server.enable = true` добавляет
  daily gc/optimise, `systemd-resolved`, key-only SSH и серверные пакеты
  (остальное уже в `modules/nixos/common.nix`).
- **Серверы ставятся** через `nixos-anywhere` + disko, см. `justfile`.

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
- `disko` — декларативная разбивка дисков для серверов (`nixos-anywhere`)

Версия релиза указана в трёх input-ах; flake-схема требует строковых
литералов в `url`, поэтому вынести её в переменную нельзя — менять синхронно.

## Как добавлять

### Пользователя (home-manager)

1. `home/users/<user>/user.nix` — identity: `username`, `fullName`, `email`
   (при необходимости `sshKeys` для NixOS-хостов).
2. `home/users/<user>/home.nix` — `imports = [ ../../common ];` плюс всё, что
   общее у юзера на всех машинах (аватар, общие `home.file`). Импортится
   каждым `<host>.nix`, включая серверы, поэтому GUI здесь не место.
3. `home/users/<user>/<host>.nix` — `imports = [ ./home.nix ];` и выбор фич:
   ```nix
   user.bundle.graphical.enable = true;      # GUI-набор
   user.bundle.linux-desktop.enable = true;  # Linux-десктоп, только на Linux
   user.desktop.kitty.enable = true;         # или отдельная фича
   ```
4. Флейк сам создаст ключ `homeConfigurations."<user>@<host>"`.
   Применение на машине: `home-manager switch --flake .#<user>@<host>`.
   Фичи с `mkOutOfStoreSymlink` (neovim/kitty/niri/rofi/keepassxc/noctalia/opencode)
   требуют локальный клон репозитория у пользователя (`~/.dotfiles`).

### Хост (NixOS)

1. `hosts/nixos/<host>/configuration.nix` + `hardware-configuration.nix`.
2. Включить профили/сервисы: `nixos.profiles.desktop.enable = true;`,
   `nixos.services.podman.enable = true;` и т.д.
3. `sudo nixos-rebuild switch --flake .#<host>`.

### Сервер (integrated home-manager)

Сервер — обычный NixOS-хост; home-manager собирается **внутри системы**
через `nixos-rebuild`, а не отдельной командой `home-manager switch`.

Цепочка сборки:

```
nixos-rebuild switch --flake .#<server>
  └─ flake.nix mkNixos           → specialArgs { inputs, primaryUser, hostname }
      └─ hosts/nixos/<server>/configuration.nix
          └─ nixos.home-manager.integrated.enable = true
              └─ modules/nixos/home-manager.nix
                  └─ import home/users/rusich/<server>.nix   (hostname → имя файла)
                      └─ ./home.nix → ../../common → readDir base + ../features
```

`useGlobalPkgs = true` — HM берёт `pkgs` из системы (одно дерево зависимостей);
активация — сервис `home-manager-rusich.service`; откат общий с системой.

1. `mkdir -p hosts/nixos/<server>` и скопировать туда
   `templates/server/{configuration.nix,disko.nix}`; `hardware-configuration.nix`
   создаст `just install` (`nixos-anywhere --generate-hardware-config`).
2. Создать `home/users/rusich/<server>.nix`:
   ```nix
   { imports = [ ./home.nix ]; }   # только база, без user.bundle.*
   ```
   Имя файла обязано совпадать с именем папки хоста (приходит как `hostname`);
   без `user.bundle.*` GUI/out-of-store фичи на сервер не попадают.
3. В конфиге хоста включены `nixos.profiles.server.enable = true;` и
   `nixos.home-manager.integrated.enable = true;` (уже есть в шаблоне).
4. Установка/обновление с десктопа:
   ```bash
   just install <server> <host-or-ip>    # nixos-anywhere, СТИРАЕТ диск
   just rebuild <server> <host-or-ip>   # nixos-rebuild --target-host
   ```
   SSH-ключи `rusich`/`root` берутся из `home/users/rusich/user.nix`.

**Доступ.** Root — только по ключу (`PermitRootLogin = "prohibit-password"`,
`PasswordAuthentication = false`). Консольный фоллбэк — пароль пользователя
`rusich` (`initialHashedPassword` из поля `hashedPassword` в
`home/users/rusich/user.nix`); сейчас там заглушка-лок, впиши хеш из
`nix shell nixpkgs#mkpasswd -c mkpasswd -m yescrypt`. Потеря ключей: локальная
консоль (`virsh console`/Cockpit/физический доступ) → вход `rusich` → `sudo`.
В планах — переход на `sops-nix`.

Не запускать на сервере standalone `home-manager switch` — получится две
конкурирующие генерации. Тот же файл доступен и как
`homeConfigurations."rusich@<server>"`, но по умолчанию используем integrated.

### Опции: где что искать

- **Система**: `nixos.profiles.*`, `nixos.services.*`, `nixos.hardware.*`,
  `nixos.virtualisation.*`, `nixos.home-manager.integrated.enable`.
- **Пользователь**: `user.<группа>.<имя>.enable` — группы `editors`, `cli`,
  `desktop`, `gui`, `pim`, `dev`, `opencode`; наборы —
  `user.bundle.{graphical,linux-desktop}.enable`.

## Устранение неполадок

```bash
nix-collect-garbage -d                                      # кэш
nix flake check                                             # зависимости
sudo nixos-rebuild switch --flake .#<host> --show-trace     # отладка сборки
```
