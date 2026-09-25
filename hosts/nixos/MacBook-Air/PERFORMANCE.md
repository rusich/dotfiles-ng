# MacBook-Air: производительность хранилища и тюнинг

Документ фиксирует результаты замеров и выводы, чтобы их можно было
воспроизводить и сравнивать (например, при экспериментах с флешками).
Контекст: MacBookAir7,2 (2015), 4 ГБ RAM, root на SD-карте через
USB-BOT-ридер (контроллер NVMe на плате мёртв).

## 1. Железо и путь ввода-вывода

| Параметр | Значение |
|---|---|
| Машина | MacBookAir7,2, kernel 6.18.52 |
| Root | `/dev/sda2` (ext4) на SD за ридером `05ac:8406` |
| Драйвер | `usb-storage` (BOT), **не UAS** |
| Очередь | `queue_depth=1`, `can_queue=1`, `nr_requests=2` |
| Прочее | `write_cache=write through`, `discard_max_bytes=0` (TRIM недоступен) |
| USB-скорость | 5000 Мбит/с (USB3), но команды сериализуются |

Вывод: **одна команда за раз**, случайные записи/чтения не параллелятся.

## 2. Базовые замеры носителей

Методика: `O_DIRECT` (мимо кэша) там, где ФС поддерживает; для USB-флешки
(iso9660) — буферизованно с `POSIX_FADV_RANDOM`. 4K = 200–2000 операций.

| Носитель | Посл. чтение | Посл. запись | Случ. 4K чтение | Случ. 4K запись |
|---|---|---|---|---|
| **SD-карта** (Apple reader, root) | 91.3 → 92.8 МБ/с | **5.0–5.1 МБ/с** | 0.41 мс (~2450 IOPS) | 1.97 мс (~507 IOPS), p99 **52 мс** |
| **AGI 128G** USB-флешка (`24a9:205a`) | **18.5 МБ/с** | — (был ISO) | 2.83 мс (~354 IOPS, буфер.) | — |
| Samsung FIT Plus 128G (`MUF-128AB`) | ~400 МБ/с* | ~60 МБ/с* | н/д | н/д |
| USB-SSD (ориентир) | 300–1000 МБ/с | 200–900 МБ/с | 10–50k IOPS | 5–30k IOPS |

\* по обзору Windows Central (синтетика, свежий носитель). FIT Plus — тоже
`usb-storage` BOT, **без UAS и TRIM**, поэтому случайный I/O у него, скорее
всего, слабый и деградирует по мере заполнения.

**Ключевой вывод:** у SD посл. запись всего ~5 МБ/с, а p99 случайной записи
52 мс — это и есть источник фризов. Флешка AGI оказалась ещё хуже карты по
чтению (в 5–7 раз), поэтому для ОС не подошла.

## 3. Системные метрики: до и после тюнинга

| Метрика | До | После (первый фикс) |
|---|---|---|
| PSI I/O `full` avg10 (простой) | **~42–44 %** | **~0.9–1 %** |
| PSI I/O `full` avg300 | ~44 % | 0.14 % |
| PSI memory | до ~26 % (промежуточно) | **0 %** |
| Load average (простой) | 4.27 | 0.32 |
| Swap used | 441 МБ (zram) + 61 МБ (sda3) | **0 Б** |
| Запись `/tmp` | на SD (~5 МБ/с) | 1.5 ГБ/с (zram) |
| Запись `/var/tmp` | на SD | 1.8 ГБ/с (tmpfs) |
| Запись кэша Firefox | на SD | 2.0 ГБ/с (tmpfs) |

## 4. Тест под тяжёлой нагрузкой (пересборка nvim-treesitter)

Сценарий: удалить runtime nvim, запустить — lazy.nvim + сборка ~45 парсеров
+ ~20 mason-пакетов. По логу монитора (`/home/rusich/psi-monitor.log`):

- `app.slice` всё время прижат к капу **2.3 ГБ**: `memory.events high = 15342`,
  OOM-килов `0`.
- `swapfree` 11.1 ГБ → 5.9 ГБ: **~5.2 ГБ ушло в своп**, из них ~2.4 ГБ — на
  медленный sda3 (тогда ещё активный).
- `io_full` до **87.8 %**, `mem_full` до **88.9 %**, `cpu_some` max **39.9 %**
  (CPU — НЕ узкое место), `app_psi` до 92 %.
- Процессы: `cc1` **1.7–1.88 ГБ**, `tree-sitter` CLI **~1.3 ГБ** на один парсер.

Вывод: это **memory-pressure ливлок + своп на медленный SD**, а не CPU.

## 5. Итоговый тюнинг (коммиты `7029dc5`, `7447d96`)

Файл: `hosts/nixos/MacBook-Air/configuration.nix`.

- **Запись:** `vm.dirty_bytes=32M`, `dirty_background_bytes=8M`,
  `dirty_expire_centisecs=1500`, `dirty_writeback_centisecs=300` — не копить
  сотни МБ грязных страниц и не вешать систему массовым сбросом.
- **Память:** `vm.swappiness=60` (умеренно, не заливать zram проактивно),
  `vm.vfs_cache_pressure=60`, `vm.page-cluster=0`.
- **zram swap = 100 % RAM** (память не резервируется).
- **sda3 → `noauto`**: диск-своп не активен в работе (свопимся только в zram),
  гибернация возможна вручную:
  `sudo swapon /dev/disk/by-uuid/d237160e-7b7a-436c-81c7-dc3451f2d789 && systemctl hibernate`.
- **earlyoom**: пороги 5 %/5 %, `--avoid` для Firefox/композитора,
  `--prefer` для компиляторов/установщиков. Страховка от «завис вместо OOM».
- **Изоляция сессии:** `app.slice` (терминалы/сборки/браузер)
  `MemoryHigh=2300M`, `CPUWeight=50`; `session.slice` (композитор niri)
  `CPUWeight=300`, `MemoryMin=200M`, `MemoryLow=400M`.
- **ФС/диск:** root `noatime,commit=30`; udev `rotational=0`,
  `read_ahead=1024`, `mq-deadline`; `/tmp` в zram (`ram/4`), `/var/tmp` tmpfs,
  кэш Firefox в tmpfs для `rusich` и `bunny`.
- **journald:** `persistent`, лимит 32 МБ (логи зависаний переживают ребут).
- **Suspend:** `usbcore.autosuspend=-1`, `usb-storage.delay_use=5`,
  фикс `fix-sd-reader` (поиск ридера по `05ac:8406`).

### Отдельно: парсер `gitcommit` (nvim)

`gbprod/tree-sitter-gitcommit` генерирует `parser.c` ~3.3 МБ; сборка пикует
**~3 ГБ** (`tree-sitter` CLI + `cc1`). На 4 ГБ вешает машину. Убран из
`ensure_installed` (`home/features/editors/neovim/config/lua/plugins/treesitter.lua`);
на мощных машинах ставить вручную: `:TSInstall gitcommit`.

## 6. Как воспроизвести замеры

Общее: перед случайными тестами нужен **writable** носитель с ФС, где
поддерживается `O_DIRECT` (ext4/f2fs). На iso9660/raw без root не выйдет.

```bash
# Последовательное чтение 512 МиБ (O_DIRECT)
BIG=$(find /nix/store -maxdepth 3 -type f -size +300M | head -1)
dd if="$BIG" of=/dev/null bs=1M count=512 iflag=direct

# Случайное чтение 4K, O_DIRECT
python3 - "$BIG" <<'PY'
import os,time,random,mmap,sys
p=sys.argv[1]; size=os.path.getsize(p)
fd=os.open(p,os.O_RDONLY|os.O_DIRECT); m=mmap.mmap(-1,4096); mv=memoryview(m)
lat=[]; n=200
for i in range(n):
    off=random.randrange(0,size-4096,4096)
    s=time.perf_counter(); os.preadv(fd,[mv],off); lat.append(time.perf_counter()-s)
del mv; os.close(fd); m.close(); lat.sort(); a=sum(lat)/n
print("avg=%.2fms p50=%.2f p95=%.2f max=%.2f ~%.0f IOPS"%(a*1e3,lat[n//2]*1e3,lat[int(n*.95)]*1e3,lat[-1]*1e3,1000/(a*1e3)))
PY

# Случайная запись 4K, O_DIRECT (пишет 256 МиБ, потом удаляет)
python3 - <<'PY'
import os,time,random,mmap
p="/home/rusich/.iotest_rand"; size=256*1024*1024
open(p,"wb").truncate(size)
fd=os.open(p,os.O_RDWR|os.O_DIRECT); m=mmap.mmap(-1,4096); mv=memoryview(m); mv[:]=b"x"*4096
lat=[]; n=2000
for i in range(n):
    off=random.randrange(0,size-4096,4096)
    s=time.perf_counter(); os.pwritev(fd,[mv],off); lat.append(time.perf_counter()-s)
os.fsync(fd); del mv; os.close(fd); m.close(); lat.sort(); a=sum(lat)/n
print("avg=%.2fms p50=%.2f p95=%.2f p99=%.2f max=%.2f ~%.0f IOPS"%(a*1e3,lat[n//2]*1e3,lat[int(n*.95)]*1e3,lat[int(n*.99)]*1e3,lat[-1]*1e3,1000/(a*1e3)))
os.unlink(p)
PY

# Последовательная запись 256 МиБ с fsync
dd if=/dev/zero of=/home/rusich/.iotest_seq bs=1M count=256 conv=fsync

# PSI и память
cat /proc/pressure/io /proc/pressure/memory
free -h; swapon --show; zramctl
```

## 7. Чеклист сравнения новой флешки

1. Воткнуть, определить: `lsblk -o NAME,SIZE,TRAN,MODEL`;
   `readlink -f /sys/block/sdX/device/driver` → `usb-storage` (BOT) или `uas`.
2. `cat /sys/block/sdX/device/queue_depth` — 1 (BOT) или >1 (UAS).
3. `cat /sys/block/sdX/queue/discard_max_bytes` — есть ли TRIM.
4. Разметить (ext4/f2fs) и смонтировать в writable-точку.
5. Прогнать замеры из раздела 6, записать в таблицу (раздел 2).
6. Для сравнения «для ОС» важны: **посл. запись**, **случ. 4K запись (p99)**,
   `queue_depth`, TRIM. Посл. чтение — вторично.

## 8. Артефакты

- Сырой лог монитора: `/home/rusich/psi-monitor.log` (PSI/память/слайсы,
  2-секундный шаг). Монитор сейчас не запущен.
- Коммиты: `2ef0955` (первичный тюнинг), `7029dc5` (память/своп/earlyoom/
  слайсы), `7447d96` (gitcommit).

## 9. Приложение: скрипт монитора PSI

Пишет на SD с `sync`, чтобы данные пережили жёсткое выключение. Запуск:
`setsid nohup ./psi-monitor.sh >/dev/null 2>&1 &`, остановка:
`pkill -f psi-monitor.sh`.

```sh
#!/bin/sh
LOG=/home/rusich/psi-monitor.log
APP=/sys/fs/cgroup/user.slice/user-1000.slice/user@1000.service/app.slice
SESS=/sys/fs/cgroup/user.slice/user-1000.slice/user@1000.service/session.slice

echo "=== monitor started $(date -Is) (pid $$) ===" >>"$LOG"
i=0
while true; do
  ts=$(date -Is)
  io=$(awk '/^some/{s=$2} /^full/{f=$2} END{printf "some=%s full=%s", s, f}' /proc/pressure/io)
  mem=$(awk '/^some/{s=$2} /^full/{f=$2} END{printf "some=%s full=%s", s, f}' /proc/pressure/memory)
  cpu=$(awk '/^some/{print $2}' /proc/pressure/cpu)
  vals=$(awk '/^MemAvailable:/{a=$2} /^SwapFree:/{s=$2} /^Dirty:/{d=$2} /^Writeback:/{w=$2} END{print a, s, d, w}' /proc/meminfo)
  set -- $vals
  appc=$(cat "$APP/memory.current" 2>/dev/null)
  sessc=$(cat "$SESS/memory.current" 2>/dev/null)
  appev=$(tr '\n' ',' <"$APP/memory.events" 2>/dev/null)
  appp=$(awk '/^some/{print $2}' "$APP/memory.pressure" 2>/dev/null)
  sessp=$(awk '/^some/{print $2}' "$SESS/memory.pressure" 2>/dev/null)
  echo "$ts io[$io] mem[$mem] cpu_some=$cpu avail_kB=$1 swapfree_kB=$2 dirty_kB=$3 wb_kB=$4 app_MB=$((appc/1048576)) sess_MB=$((sessc/1048576)) app_psi=$appp sess_psi=$sessp app_ev=[$appev]" >>"$LOG"
  if [ $((i % 5)) -eq 0 ]; then
    echo "  $(date -Is) topmem: $(ps -eo rss=,comm= --sort=-rss 2>/dev/null | head -3 | tr -s ' ' | tr '\n' '|')" >>"$LOG"
  fi
  sync -d "$LOG" 2>/dev/null || true
  i=$((i + 1))
  sleep 2
done
```
