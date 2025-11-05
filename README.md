# Организация модулей NixOS с автоматической и ручной загрузкой

## Итоговая структура

```
lib/
└── modules.nix              # Утилитарные функции для работы с модулями

modules/
└── nixos/
    ├── default.nix          # Основной модуль с логикой автозагрузки
    ├── host-type.nix        # Кастомные опции для типа хоста
    ├── desktop.nix          # Ручной модуль
    ├── development.nix      # Ручной модуль
    ├── auto/                # Автоматические модули
    │   ├── common/          # Общие для всех хостов
    │   │   └── base.nix
    │   ├── workstations/    # Только для рабочих станций
    │   │   └── desktop.nix
    │   └── servers/         # Только для серверов
    │       └── services.nix
    └── optional/            # Дополнительные категории (не автозагружаемые)
        ├── hardware/
        └── services/
```

## Основные компоненты

### 1. Утилитарные функции в lib/

```nix
# lib/modules.nix
{ lib }:

{
  # Функция для загрузки всех модулей из каталога
  loadModulesFromDir = dir:
    let
      files = builtins.attrNames (builtins.readDir dir);
      nixFiles = builtins.filter (f: lib.hasSuffix ".nix" f) files;
    in
      map (f: dir + "/${f}") nixFiles;

  # Функция для условной загрузки модулей по типу хоста
  loadConditionalModules = config: autoModulesPath:
    let
      commonModules = loadModulesFromDir (autoModulesPath + "/common");
      workstationModules = loadModulesFromDir (autoModulesPath + "/workstations");
      serverModules = loadModulesFromDir (autoModulesPath + "/servers");
    in
      commonModules ++ (
        if config.host.type == "workstation" then workstationModules
        else if config.host.type == "server" then serverModules
        else []
      );
}
```

### 2. Модуль с кастомными опциями

```nix
# modules/nixos/host-type.nix
{ lib, ... }:

{
  options = {
    host.type = lib.mkOption {
      type = lib.types.enum [ "workstation" "server" "laptop" ];
      default = "server";
      description = "Type of the host system";
    };
    
    host.role = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Specific role of the host";
    };
  };
}
```

### 3. Основной модуль с логикой автозагрузки

```nix
# modules/nixos/default.nix
{ config, lib, ... }:

let
  # Импортируем утилитарные функции
  modulesLib = import ../../lib/modules.nix { inherit lib; };
  
  # Путь к автоматическим модулям
  autoModulesPath = ./auto;
  
  # Автоматически загружаемые модули
  autoModules = modulesLib.loadConditionalModules config autoModulesPath;
  
in
{
  imports = autoModules;
  
  # Импортируем модуль с кастомными опциями
  imports = [ ./host-type.nix ];
}
```

### 4. Примеры автоматических модулей

#### Общие модули (для всех хостов)
```nix
# modules/nixos/auto/common/base.nix
{ config, pkgs, ... }:

{
  # Общие настройки для всех хостов
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
    htop
  ];
  
  programs.zsh.enable = true;
}
```

#### Модули для рабочих станций
```nix
# modules/nixos/auto/workstations/desktop.nix
{ config, lib, ... }:

lib.mkIf (config.host.type == "workstation") {
  # Настройки только для рабочих станций
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  hardware.pulseaudio.enable = true;
  
  environment.systemPackages = with config.pkgs; [
    firefox
    vlc
    gimp
  ];
}
```

#### Модули для серверов
```nix
# modules/nixos/auto/servers/services.nix
{ config, lib, ... }:

lib.mkIf (config.host.type == "server") {
  # Настройки только для серверов
  services.openssh.enable = true;
  services.fail2ban.enable = true;
  
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };
  
  environment.systemPackages = with config.pkgs; [
    htop
    iotop
    nload
  ];
}
```

### 5. Примеры ручных модулей

```nix
# modules/nixos/desktop.nix
{ config, pkgs, ... }:

{
  # Ручной модуль для десктоп окружений
  # Подключается явно в configuration.nix хоста
  
  services.xserver = {
    enable = true;
    desktopManager = {
      xfce.enable = true;
      gnome.enable = false;
      plasma5.enable = false;
    };
    displayManager = {
      lightdm.enable = true;
      defaultSession = "xfce";
    };
  };
  
  environment.systemPackages = with pkgs; [
    libreoffice
    gimp
    inkscape
  ];
}
```

```nix
# modules/nixos/development.nix
{ config, pkgs, ... }:

{
  # Ручной модуль для разработки
  # Подключается явно в configuration.nix хоста
  
  environment.systemPackages = with pkgs; [
    vscode
    jetbrains.idea-ultimate
    docker
    nodejs
    python3
    rustup
  ];
  
  virtualisation.docker.enable = true;
  
  programs.java.enable = true;
}
```

### 6. Использование в configuration.nix хостов

```nix
# hosts/nixos/matebook/configuration.nix
{ config, pkgs, ... }:

{
  # Автоматически загружаемые модули через modules/nixos/default.nix
  imports = [ ../../../modules/nixos ];
  
  # Определяем тип хоста
  host.type = "workstation";
  host.role = "development-laptop";
  
  # Ручные модули (подключаем явно)
  imports = [
    ../../../modules/nixos/development.nix
  ];
  
  # Специфичные настройки для хоста
  boot.loader.systemd-boot.enable = true;
  networking.hostName = "matebook";
  # ... остальные настройки
}
```

## Преимущества структуры

- **Автоматическая загрузка**: Модули в `auto/` загружаются автоматически в зависимости от типа хоста
- **Ручной контроль**: Модули в корне `modules/nixos/` подключаются явно через imports
- **Переиспользуемые утилиты**: Утилитарные функции вынесены в `lib/` для повторного использования
- **Гибкость**: Легко добавлять новые категории модулей
- **Идиоматичность**: Использует стандартные механизмы NixOS
- **Масштабируемость**: Подходит для любого количества хостов и типов систем


# Tips

## Как использовать

### Настройка нового хоста

1. Создайте каталог для хоста:
```bash
mkdir -p hosts/nixos/${hostname}
```

2. Сгенерируйте hardware-configuration.nix:
```bash
nixos-generate-config --show-hardware-config > hosts/nixos/${hostname}/hardware-configuration.nix
```

3. Создайте configuration.nix:
```nix
# hosts/nixos/${hostname}/configuration.nix
{ config, pkgs, ... }:

{
  # Автоматически загружаемые модули
  imports = [ ../../../modules/nixos ];
  
  # Определяем тип хоста
  host.type = "workstation";  # или "server", "laptop"
  host.role = "development";
  
  # Ручные модули (подключаем явно)
  imports = [
    ../../../modules/nixos/development.nix
    ../../../modules/nixos/desktop.nix
  ];
  
  # Специфичные настройки для хоста
  boot.loader.systemd-boot.enable = true;
  networking.hostName = "${hostname}";
}
```

### Добавление новых модулей

- **Автоматические модули**: Добавляйте в соответствующие подкаталоги `auto/`
- **Ручные модули**: Создавайте в корне `modules/nixos/` и подключайте через imports
- **Утилитарные функции**: Добавляйте в `lib/` для повторного использования

### Обновление структуры

```bash
# Создайте каталог lib если его нет
mkdir -p lib

# Создайте файл с утилитарными функциями
cat > lib/modules.nix << 'EOF'
{ lib }:

{
  loadModulesFromDir = dir:
    let
      files = builtins.attrNames (builtins.readDir dir);
      nixFiles = builtins.filter (f: lib.hasSuffix ".nix" f) files;
    in
      map (f: dir + "/${f}") nixFiles;

  loadConditionalModules = config: autoModulesPath:
    let
      commonModules = loadModulesFromDir (autoModulesPath + "/common");
      workstationModules = loadModulesFromDir (autoModulesPath + "/workstations");
      serverModules = loadModulesFromDir (autoModulesPath + "/servers");
    in
      commonModules ++ (
        if config.host.type == "workstation" then workstationModules
        else if config.host.type == "server" then serverModules
        else []
      );
}
EOF
```
