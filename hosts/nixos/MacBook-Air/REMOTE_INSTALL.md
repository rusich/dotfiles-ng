# MacBook-Air: установка NixOS по сети (REMOTE_INSTALL)

Документ описывает **единственный рабочий** способ удалённой (пере)установки
NixOS на этот ноутбук. Написан так, чтобы исполнитель (человек или ИИ-агент)
мог воспроизвести процесс однозначно и не повторить тупики.

**Контекст:** MacBookAir7,2 (2015), 4 ГБ RAM, внутренний NVMe мёртв — система
живёт на USB-флешке (Samsung FIT Plus, см. `PERFORMANCE.md`). Управление — по
SSH с рабочей станции (`~/.dotfiles`, рецепт `just install`).

---

## 0. TL;DR — что делать

Смысл: загрузить цель **обычной прошивочной загрузкой** в инсталлятор (не
kexec!), после чего `nixos-anywhere` увидит, что это уже инсталлятор, и просто
выполнит disko + установку по сети.

1. Собрать образ инсталлятора (ядро+initrd) — раздел 3.
2. Через SSH на работающей цели положить файлы на её **ESP** и добавить запись
   systemd-boot — раздел 4.
3. Перезагрузить цель (`systemctl reboot`). Она грузится с ESP в RAM-инсталлятор.
4. С рабочей станции: `just install MacBook-Air <IP>` (на запрос — `yes`),
   `nixos-anywhere` пропустит kexec и поставит систему — раздел 5.
5. Пост-проверка — раздел 6.

Если сменился носитель — сначала поправить `disko.nix` (раздел 7).

---

## 1. Почему НЕЛЬЗЯ через обычный `kexec`

`just install` без специальной подготовки использует kexec (по умолчанию
`nixos-anywhere` грузит инсталлятор через kexec). **На этом ноутбуке kexec
нерабочий:**

- kexec-загрузка **проходит** (в консоли видно `machine will boot into nixos`,
  затем systemd стартует), НО после kexec **мертвы USB, SPI-клавиатура и Wi-Fi
  (Broadcom PCIe)** — живым остаётся только дисплей. Сеть не поднимается →
  `nixos-anywhere` обрывается (`Connection timed out` / `No route to host`).
- Проверено на нескольких образах; добавление модулей (`xhci_pci`, `applespi`,
  `spi_pxa2xx_*`, `bcm5974`, `hid_apple`, `applesmc`, `ax88179_178a`) в initrd
  **не помогает** — то есть это особенность железа Apple после kexec, а не
  нехватка модулей.
- Побочный симптом: после первой неудачной попытки машина ~30 мин недоступна,
  пока её не перезагрузят вручную.

**Вывод: kexec на этой машине не использовать.** Рабочий путь — обычная загрузка
прошивкой (BIOS/systemd-boot), т.е. установщик надо предварительно положить на
носитель и выбрать его при загрузке.

> Вариант с внешней флешкой/ISO тоже рабочий (раздел 8), но здесь описан
> **полностью сетевой** способ: без дополнительных носителей, только ESP и SSH.

---

## 2. Рабочая схема: ESP-инсталлятор + `nixos-anywhere`

1. На работающей цели (любая текущая NixOS с SSH) кладём `bzImage` + `initrd`
   инсталлятора в каталог на **ESP** (`/boot`) и добавляем запись systemd-boot.
2. `systemctl reboot` — это **штатная** загрузка прошивкой (не kexec), поэтому
   USB/клавиатура/Wi-Fi инициализируются нормально.
3. Инсталлятор запускается целиком из RAM (initrd + squashfs), сеть — по проводу.
4. `nixos-anywhere` по SSH определяет на цели `VARIANT_ID="installer"` (см.
   `installation-device.nix` в nixpkgs) и **пропускает фазу kexec**, сразу выполняя
   disko + `nixos-install`.
5. После установки и ребута ESP перезаписан (disko), старая запись инсталлятора
   исчезает — грузится новая система.

Сеть в инсталляторе: **проводной USB-NIC (ASIX AX88179, `0b95:1790`,
MAC `00:90:54:5c:9a:d4`) — основной путь**; обычно получает `192.168.5.36`.
Wi-Fi (`wl`) в инсталляторе ненадёжен — не полагаться на него.

---

## 3. Сборка ESP-инсталлятора (ядро + initrd)

Модуль ниже — **минимальный netboot на базе nixpkgs флейка** с драйверами железа
Apple и USB-NIC, SSH-ключом рабочей станции и включённым NetworkManager.

Сохранить как `/tmp/esp-installer.nix`:

```nix
{ config, lib, pkgs, modulesPath, ... }:
let
  # Модули железа MacBookAir7,2: xHCI (USB), Apple SPI (клавиатура/тачпад),
  # SMC и драйвер USB-NIC ASIX AX88179 — иначе инсталлятор поднимается «слепым».
  hwModules = [
    "xhci_pci" "usb_storage" "usbhid" "sd_mod" "usbcore" "scsi_mod" "ext4"
    "usbnet" "mii" "ax88179_178a"
    "applespi" "spi_pxa2xx_core" "spi_pxa2xx_pci" "spi_pxa2xx_platform"
    "bcm5974" "hid_apple" "applesmc"
  ];

  # Ядро + initrd + cmdline для загрузки через systemd-boot с ESP.
  espInstaller = pkgs.runCommand "nixos-esp-installer" { } ''
    mkdir -p $out
    cp "${config.system.build.kernel}/${config.system.boot.loader.kernelFile}" $out/bzImage
    cp "${config.system.build.netbootRamdisk}/initrd" $out/initrd
    cat > $out/cmdline <<EOF
    init=${config.system.build.toplevel}/init root=fstab nohibernate loglevel=4 lsm=landlock,yama,bpf
    EOF
  '';
in
{
  imports = [ (modulesPath + "/installer/netboot/netboot-minimal.nix") ];

  system.stateVersion = lib.trivial.release;
  networking.hostName = "nixos-installer";

  # SSH-доступ для nixos-anywhere (публичный ключ рабочей станции).
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjQLNoxeO2BVnnYlmYWLUntVj4w2Der89NG5qm0w6u/ rusich@darkstar"
  ];

  system.installer.channel.enable = false;
  environment.systemPackages = with pkgs; [ disko nixos-install-tools jq rsync ];

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  boot.initrd.availableKernelModules = hwModules;
  boot.initrd.kernelModules = hwModules;
  boot.kernelModules = hwModules;

  # netboot-minimal принудительно выключает NM — включаем обратно для DHCP по проводу.
  networking.networkmanager.enable = lib.mkForce true;

  system.build.espInstaller = espInstaller;
}
```

Собрать (из корня репозитория; берём nixpkgs самого флейка, чтобы совпадало ядро):

```bash
cd ~/.dotfiles
NIXPKGS=$(nix eval --raw '.#nixosConfigurations.MacBook-Air.pkgs.path')
nix build --impure --no-link --print-out-paths --expr "
let nixpkgs = $NIXPKGS; in
(import (nixpkgs + \"/nixos/lib/eval-config.nix\") {
  system = \"x86_64-linux\";
  modules = [ /tmp/esp-installer.nix ];
}).config.system.build.espInstaller"
```

Результат — каталог `/nix/store/<hash>-nixos-esp-installer` с файлами:

| Файл | Размер | Назначение |
|---|---|---|
| `bzImage` | ~13 МБ | ядро (для `linux` в записи systemd-boot) |
| `initrd` | ~0.5 ГБ | initramfs + squashfs системы (для `initrd`) |
| `cmdline` | — | опции ядра (`options`) |

Проверка (опционально): в initrd должны быть нужные модули:

```bash
zstd -dc <initrd> | cpio -t 2>/dev/null | grep -E 'ax88179|xhci-pci'
```

> **Размер:** initrd ~0.5 ГБ → на ESP (у нас 1 ГБ) запас есть, но учитывайте это.
> Старый (неудачный) Wi-Fi-образ из broadcom-sta давал initrd ~1.36 ГБ — из-за
> размера он мог не грузиться на 4 ГБ RAM; здесь это не проблема.

---

## 4. Размещение на ESP и запись systemd-boot

Выполняется **на работающей цели** (текущая NixOS), по SSH с рабочей станции.
`<IP>` — адрес цели (провод или Wi-Fi), `<IMG>` — путь из раздела 3.

```bash
# 1) каталог на ESP
ssh root@<IP> 'mkdir -p /boot/nixos-installer'

# 2) залить ядро и initrd (по проводу ~1 Gbps; ~0.5 ГБ)
scp <IMG>/bzImage <IMG>/initrd <IMG>/cmdline root@<IP>:/boot/nixos-installer/

# 3) запись systemd-boot + сделать её дефолтной
ssh root@<IP> 'bash -s' <<'EOF'
OPTS=$(cat /boot/nixos-installer/cmdline)
cat > /boot/loader/entries/nixos-installer.conf <<CONF
title NixOS installer (ESP)
linux /nixos-installer/bzImage
initrd /nixos-installer/initrd
options $OPTS
CONF
sed -i 's/^default .*/default nixos-installer.conf/' /boot/loader/loader.conf
cat /boot/loader/entries/nixos-installer.conf
cat /boot/loader/loader.conf
EOF
```

Проверь, что свободного места на ESP хватает (`df -h /boot`) и что
`/boot/loader/loader.conf` теперь содержит `default nixos-installer.conf`.

Перезагрузить цель:

```bash
ssh root@<IP> 'systemctl reboot'
```

После ребута инсталлятор поднимается из RAM: в консоли виден `nixos-installer
login: nixos (automatic login)`. Проводной порт получает DHCP-адрес.

---

## 5. Запуск установки

Найти адрес инсталлятора (обычно тот же `192.168.5.36` по проводу; можно искать
по MAC `00:90:54:5c:9a:d4`):

```bash
ping -c2 192.168.5.36
```

Убедиться, что это инсталлятор (новый SSH-ключ хоста — это нормально):

```bash
ssh-keygen -R 192.168.5.36 2>/dev/null
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.5.36 \
  'hostname; grep VARIANT_ID /etc/os-release'   # → nixos-installer, VARIANT_ID="installer"
```

Запустить установку (интерактивно: ввести `yes`; `--kexec` НЕ нужен — фаза kexec
будет пропущена автоматически):

```bash
cd ~/.dotfiles
just install MacBook-Air 192.168.5.36
```

Что произойдёт: `nixos-anywhere` загрузит свой SSH-ключ, определит
`VARIANT_ID=installer`, пропустит kexec, выполнит `disko` (разметка по
`disko.nix`) и `nixos-install --flake .#MacBook-Air`, затем перезагрузит цель.

---

## 6. Пост-проверка

После перезагрузки (новая система; SSH-ключ хоста снова новый):

```bash
ssh-keygen -R 192.168.5.36 2>/dev/null
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.5.36 'bash -s' <<'EOF'
grep -E '^(ID|VARIANT_ID|VERSION)=' /etc/os-release   # VARIANT_ID пуст → это установленная система
ls -l /nix/var/nix/profiles/system                    # ожидаем system-1-link
findmnt -no SOURCE,FSTYPE,OPTIONS /                   # by-partlabel/root, ext4, noatime,commit=60
findmnt -no SOURCE,FSTYPE /boot                       # by-partlabel/ESP, vfat
lsblk -o NAME,SIZE,FSTYPE,PARTLABEL,MOUNTPOINT        # ESP / swap / root
swapon --show                                         # только zram (дисковый swap = noauto)
tr ' ' '\n' < /proc/cmdline | grep resume=             # resume=/dev/disk/by-partlabel/swap
command -v bootctl >/dev/null && bootctl status | grep -i 'systemd-boot\|Current Entry'
EOF
```

Ожидаемо: NixOS 26.05, генерация `system-1`, `/` = ext4 `noatime,commit=60`,
`/boot` = vfat ESP, partlabels `ESP`/`swap`/`root`, активен только zram,
`resume=` указывает на раздел swap, bootloader — systemd-boot.

---

## 7. Смена диска / нового носителя

disko таргетит носитель **по by-id** (буквы `sda`/`sdb` на этой машине плавают:
SD-ридер Apple даёт пустой `sdX`, и порядок недетерминирован).

Текущее значение в `hosts/nixos/MacBook-Air/disko.nix`:

```
device = lib.mkDefault "/dev/disk/by-id/usb-Samsung_Flash_Drive_FIT_0374525090001858-0:0";
```

При смене флешки:

```bash
# на цели с новым носителем:
ls -l /dev/disk/by-id/ | grep -i usb        # взять ...-0:0 нужного устройства
```

и обновить `device` в `disko.nix` (или разово переопределить `disko.devices.disk.disk1.device`).
Затем обычный `just install` (по описанной схеме).

Прочие требования: ESP ≥ ~0.6 ГБ (у нас 1 ГБ); носитель должен переживать
suspend (критерии — `PERFORMANCE.md`, раздел 10.1).

---

## 8. Альтернатива: обычный installer ISO (без ESP-трюка)

Если целевая система не поднимается (нет текущей NixOS с SSH) — загрузиться в
инсталлятор с внешнего носителя:

1. Записать NixOS-ISO на SD/USB, загрузить цель с него (Apple: зажать `Option`,
   выбрать «EFI Boot»). Это обычная загрузка — железо работает.
2. Дать рабочей станции доступ по SSH: либо использовать ISO со вшитым
   `authorized_keys` (как в этом документе — в модуль можно добавить `users.users.root.openssh.authorizedKeys.keys`),
   либо на консоли инсталлятора добавить ключ:
   ```bash
   mkdir -p /root/.ssh && echo '<pubkey>' >> /root/.ssh/authorized_keys
   ```
3. Дальше как в разделе 5: `just install MacBook-Air <IP>` — `nixos-anywhere`
   увидит `VARIANT_ID=installer` и пропустит kexec.

У пользователя есть собственный проект кастомного ISO с Wi-Fi/Broadcom
(`~/Nextcloud/Devel/nix/custom-nixos-iso-MacBook-Air`) — годится как основа
(но учти: там unfree broadcom-sta и тяжёлая сборка).

---

## 9. Грабли и обязательные условия (частые ошибки)

- **Не использовать kexec** (см. раздел 1). Признак тупика: после «kexec загрузился»
  машина недоступна, `ip a` в консоли — только `lo`.
- **Загрузчик обязан быть в `configuration.nix`.** `--generate-hardware-config`
  (его выполняет `just install`) **перегенерирует** `hardware-configuration.nix` и
  boot-секцию не сохраняет. Без этого падает `grub`-assertion
  (`You must set the option 'boot.loader.grub.devices'`). В репозитории
  `boot.loader.systemd-boot.enable`/`efi.canTouchEfiVariables` заданы в
  `configuration.nix`; в `hardware-configuration.nix` их дублировать не нужно.
- **disko — только по by-id** (раздел 7); иначе рискуете затереть не тот носитель.
- **Инсталлятор работает из RAM.** Разметка диска, с которого загрузились (ESP),
  безопасна; старые файлы ESP исчезнут — это ожидаемо.
- **Сеть в инсталляторе — провод (AX88179).** Wi-Fi (`wl`) в инсталляторе
  ненадёжен. Держите USB-NIC подключённым.
- **SSH-ключ рабочей станции должен быть вшит в образ** (поле
  `users.users.root.openssh.authorizedKeys.keys`), иначе `nixos-anywhere` не
  сможет зайти и залить свой ключ.
- **После установки Wi-Fi-креды не декларативны** — новая система не знает
  домашний Wi-Fi. Заходите по проводу (NIC поддержан в установленной системе),
  либо настраивайте Wi-Fi заново.
- **`just install` перезапишет `hosts/nixos/MacBook-Air/hardware-configuration.nix`**
  на рабочей станции — это нормально, файл сгенерированный.
- **Размер ESP:** initrd ~0.5 ГБ; при ESP 1 ГБ запас есть (следите за `df -h /boot`).
- **Apple NVRAM/efivars:** загрузка через systemd-boot на ESP; отдельные EFI-записи
  не обязательны.

---

## 10. Шпаргалка

| Что | Значение |
|---|---|
| Итоговая модель | обычная загрузка с ESP (systemd-boot) → инсталлятор в RAM → `nixos-anywhere` (kexec пропущен) |
| kexec | **нерабочий** на этом железе — не использовать |
| Провод (NIC) | ASIX AX88179 (`0b95:1790`), MAC `00:90:54:5c:9a:d4`, обычно `192.168.5.36` |
| Wi-Fi | `wlp3s0` (`wl`), обычно `192.168.5.49`; в инсталляторе ненадёжен |
| SSH-ключ образа | `ssh-ed25519 AAAA…rusich@darkstar` (рабочая станция) |
| Сборка образа | `modules = [ /tmp/esp-installer.nix ]` → `system.build.espInstaller` (см. раздел 3) |
| Файлы образа | `bzImage` (~13 МБ), `initrd` (~0.5 ГБ), `cmdline` |
| ESP-запись | `/boot/nixos-installer/{bzImage,initrd,cmdline}` + `/boot/loader/entries/nixos-installer.conf` |
| Установка | `just install MacBook-Air <IP>` (ввести `yes`) |
| disko-устройство | `/dev/disk/by-id/usb-Samsung_Flash_Drive_FIT_0374525090001858-0:0` |
| Загрузчик | `boot.loader.systemd-boot` — в `configuration.nix` (НЕ в `hardware-configuration.nix`) |
| Ребилд после | `just rebuild MacBook-Air <IP>` (или `sudo nixos-rebuild switch --flake ~/.dotfiles#MacBook-Air` на самой машине) |

**История ключевых правок в репозитории:**

- Переход раскладки на disko: `feat(macbook-air): migrate disk layout to disko`.
- Фикс «загрузчик теряется при регенерации»: `fix(macbook-air): keep bootloader
  across installs, pin disk by-id` (перенос systemd-boot в `configuration.nix`,
  disko-устройство по by-id).
- Документ `PERFORMANCE.md` — про носители, suspend и тюнинг (не про установку).
