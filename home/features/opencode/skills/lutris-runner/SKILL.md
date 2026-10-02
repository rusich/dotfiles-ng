---
name: lutris-runner
description: Use when adding, wiring, or fixing an emulator runner or a Wine game in Lutris on this NixOS dotfiles setup — "добавь эмулятор/раннер в Lutris", "раннер не виден в Lutris", "вместо работы кнопка Download", RPCS3/Ryujinx/Dolphin/PCSX2/DuckStation, добавление ядра libretro, или выбор пути Wine-префикса.
---

# Lutris: подключение эмуляторов (раннеров)

## Когда использовать
- Просят добавить/расширить эмулятор в Lutris (RPCS3, Ryujinx, Dolphin, PCSX2, DuckStation, libretro и т.п.).
- Lutris не видит раннер или предлагает Download вместо работы.
- Нужно добавить или отфильтровать ядро libretro.

## Принцип
Lutris считает раннер установленным, если существует файл по пути `runner_executable` **относительно** `~/.local/share/lutris/runners/`. Пакет ставим в NixOS, а в Lutris подкладываем симлинк (декларативно) — тогда Lutris ничего не качает.

Файлы:
- `modules/nixos/gaming.nix` — пакеты и `services.udev.packages`.
- `home/features/gaming/lutris.nix` — activation-симлинки; включается `user.gaming.lutris.enable` (у rusich в `home/users/rusich/darkstar.nix`).

## Как добавить раннер
1. Найти ожидаемый путь:
   ```
   grep -Hn runner_executable /nix/store/*lutris-unwrapped*/lib/python*/site-packages/lutris/runners/*.py
   ```
2. `modules/nixos/gaming.nix`: добавить пакет в `environment.systemPackages`. Проверить, есть ли у пакета udev-правила (`etc/udev/rules.d/*.rules`, например у `rpcs3` и `dolphin-emu`) — если да, добавить пакет в `services.udev.packages = [ ... ];`.
3. `home/features/gaming/lutris.nix` — создать каталог раннера и симлинк (в реальном файле `mkdir -p` перечисляет каталоги, добавь туда свой):
   ```nix
   run mkdir -p "${runnersDir}/<runner>"
   run ln -sfn "${pkgs.<pkg>}/bin/<bin>" "${runnersDir}/<runner>/<expected>"
   ```
4. `just switch` + `just home`, затем перезапустить Lutris (раннеры и ядра читаются при старте).

## libretro-ядро
Два места: список `retroarch.withCores` (даёт `.so`) **и** симлинк `info/<id>_libretro.info`. id = имя ядра, дефисы → подчёркивания (`genesis-plus-gx` → `genesis_plus_gx`). Каталог `info/` намеренно содержит только установленные ядра — иначе в списке 291 ядро при 5 рабочих (`rm -rf info; mkdir -p info; ln -sfn` в activation).

## Альтернатива без симлинка
Advanced-опция раннера «Custom executable for the runner» (Preferences → Runners) → указать `/run/current-system/sw/bin/<bin>`. Stateful (GUI) и не покрывает вспомогательные каталоги (cores/info libretro, ключи Ryujinx).

## Wine-префиксы
У Lutris **нет** глобальной настройки дефолтного префикса: если у игры `prefix` не задан, берётся `$WINEPREFIX` или `find_prefix(exe)`, иначе виновский `~/.wine`. Поэтому у каждой Wine-записи префикс задаём **явно**:
`~/.local/share/lutris/prefixes/<slug>` (один префикс на игру; для связанных приложений — общий, напр. DCS + updater + Kneeboard).
- Не держать префиксы в `~/Games` рядом с папками игр; не на exfat/NTFS (нужны симлинки/права); лучше локальный ext4/btrfs.
- В конфиге игры это `game.prefix` (Game options → Wine prefix).
- Перенос префикса безопасен: `mv` + правка пути (`dosdevices` относительные).
- Префиксы содержат сохранения/настройки — включать в бэкап.

## Частые ошибки
- Нажали **Remove** у раннера — удалит наш каталог и симлинки. Не нажимать.
- Не создали каталог раннера (`mkdir -p`) — симлинк упадёт при первой активации.
- Имя ожидаемого файла версионно-зависимо (`...-2512-...` и т.п.) и меняется при апгрейде Lutris — источник истины всегда `grep runner_executable`, а не quick reference.
- Не сделали `git add` новых файлов — flake игнорирует untracked (dirty git tree).
- Не перезапустили Lutris — остаётся старый список раннеров/ядер.
- Для libretro обновили `.so`, но забыли `info` (или наоборот).

## Quick reference: runner_executable
`rpcs3/rpcs3` · `ryujinx/publish/Ryujinx` · `retroarch/retroarch` (+ `cores/`, `info/`) · `cemu/Cemu` · `pcsx2/PCSX2` · `duckstation/DuckStation-x64.AppImage` · `dolphin/Dolphin_Emulator-2512-anylinux-x86_64.AppImage` · `mame/mame` · `xenia/xenia_canary.exe`
