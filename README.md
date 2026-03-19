# NixOS Configuration

Мой набор конфигураций для NixOS, nix-darwin и home-manager, использующий flakes.

## Структура проекта

```
.
├── flake.nix          # Основной flake файл
├── flake.lock         # Зависимости flakes
├── hosts/             # Конфигурации хостов
│   ├── nixos/         # Конфигурации NixOS
│   │   ├── darkstar/  # Конфигурация для хоста darkstar
│   │   ├── matebook/  # Конфигурация для хоста matebook
│   │   └── nixos-vm/  # Конфигурация для виртуальной машины
│   └── darwin/        # Конфигурации Darwin (macOS)
├── modules/           # Общие модули
├── overlays/          # Кастомные overlays
└── pkgs/              # Кастомные пакеты
```

## Первоначальная настройка на новой системе NixOS

### 1. Включение экспериментальных функций flakes

Перед использованием этой конфигурации необходимо включить экспериментальные функции flakes в Nix. Добавьте следующие строки в `/etc/nixos/configuration.nix`:

```nix
{
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

Или добавьте флаги в командной строке при запуске nix команд:

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
```

### 2. Клонирование репозитория

```bash
git clone https://github.com/rusich/dotfiles-ng.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. Установка конфигурации для конкретного хоста

#### Для хоста `darkstar`:

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#darkstar
```


### 4. Обновление конфигурации

Для обновления всех входов (inputs) flakes:

```bash
nix flake update
```

Для применения обновлений:

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#<hostname>
```

### 5. Управление поколениями (generations)

Просмотр доступных поколений:

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

Откат к предыдущему поколению:

```bash
sudo nixos-rebuild switch --rollback
```

### 6. Домашняя конфигурация (home-manager)

Для применения домашней конфигурации:

```bash
home-manager switch --flake ~/.dotfiles#rusich
```

## Особенности конфигурации

### Входы (inputs)

Конфигурация использует следующие основные входы:
- `nixpkgs` (25.11 stable)
- `nixpkgs-unstable` (нестабильная ветка)
- `home-manager` (25.11)
- `nix-darwin` (для macOS)
- `stylix` (темизация)
- Дополнительные пакеты и утилиты

### Overlays

Кастомные overlays находятся в директории `overlays/` и включают:
- Обновления для специфичных пакетов
- Кастомные сборки
- Патчи для существующих пакетов

## Устранение неполадок

### Проблемы с кэшем

Если возникают проблемы с кэшем, можно очистить его:

```bash
nix-collect-garbage -d
```

### Проблемы с зависимостями

Для проверки зависимостей:

```bash
nix flake check
```

### Проблемы с сборкой

Для отладки сборки:

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#<hostname> --show-trace
```
