# MacBook-Air: производительность хранилища и тюнинг

Документ фиксирует результаты замеров и выводы, чтобы их можно было
воспроизводить и сравнивать (например, при экспериментах с флешками).
Контекст: MacBookAir7,2 (2015), 4 ГБ RAM, контроллер NVMe на плате мёртв,
поэтому система живёт на USB-носителе.

**История:** изначально root был на **SD-карте** через Apple-ридер
(`05ac:8406`). SD оказалась проблемной: посл. запись ~4 МБ/с, а при
suspend/resume ридер отваливался → краш. Затем систему **клонировали
на USB-флешку AGI** (`24a9:205a`) — быстрее, suspend работает. Позже
по результатам замеров (раздел 2) переехали на **Samsung FIT Plus**
(`04e8:6300`) — быстрее AGI во всём. **Актуальный носитель — Samsung.**

## 1. Железо и путь ввода-вывода

| Параметр | Значение |
|---|---|
| Машина | MacBookAir7,2, kernel 6.18.52 |
| Root | `/dev/sda2` (ext4) на **USB-флешке Samsung FIT Plus** `04e8:6300` (с 2026-09-26) |
| Было | AGI-флешка `24a9:205a`; до неё — SD за Apple-ридером `05ac:8406` (медленно + suspend крашил) |
| Драйвер | `usb-storage` (BOT), **не UAS** |
| Очередь | `queue_depth=1` |
| Прочее | TRIM недоступен (`discard_max_bytes=0` у всех) |
| USB-скорость | 5000 Мбит/с (USB3), но команды сериализуются |

Вывод: **одна команда за раз**, случайные записи/чтения не параллелятся.

## 2. Базовые замеры носителей

Методика: **`O_DIRECT` (мимо кэша)** для всех носителей на writable ext4.
4K = 2000 операций. Посл. чтение — 512 МиБ, посл. запись — 256 МиБ с
`fsync`. Ранние замеры AGI (18.5 МБ/с, 2.83 мс) были сделаны **буферизованно**
по read-only iso9660 и оказались артефактом метода — заменены на честный
O_DIRECT ниже.

| Носитель (FS, метод) | Посл. чтение | Посл. запись | Случ. 4K чтение | Случ. 4K запись |
|---|---|---|---|---|
| **SD-карта** (Apple reader, ext4, O_DIRECT) | 93.1 МБ/с | **4.3 МБ/с** | 0.41 мс (~2450 IOPS) | avg 2.65 мс, p50 1.42, p99 **53.4 мс**, ~377 IOPS |
| **AGI 128G** USB, порт 2-1 (ext4, O_DIRECT) | 97.9 МБ/с | 42.4 МБ/с | 0.85 мс (~1178 IOPS) | avg 5.28 мс, p50 3.13, p99 26.2 мс, ~189 IOPS |
| **AGI 128G** USB, порт 2-2 (ext4, O_DIRECT) | **128 МБ/с** | 39.7 МБ/с | 0.76 мс (~1323 IOPS) | avg 5.21 мс, p50 3.00, p99 30.3 мс, ~192 IOPS |
| **Samsung FIT Plus 128G** (`MUF-128AB`, `04e8:6300`), порт 2-1 (ext4, O_DIRECT, **5 прогонов**) | **360 МБ/с** | **58.5 МБ/с** | 0.40 мс, p99 0.59 (~2522 IOPS) | avg 0.18 мс, p50 0.14, p99 **0.31 мс**, ~5563 IOPS |
| USB-SSD (ориентир) | 300–1000 МБ/с | 200–900 МБ/с | 10–50k IOPS | 5–30k IOPS |

**Текущий носитель:** Samsung FIT Plus на **порту 2-2** (`sda`, `04e8:6300`),
root `/dev/sda2`. AGI работал на том же порту 2-2.

### Samsung FIT Plus — живые замеры

Проведено **5 прогонов** O_DIRECT (`raw-bench.sh` + 4× на смонтированном
носителе), порт **2-1**. Разброс маленький, цифры стабильны:

| Тест | прогон 1 | 2 | 3 | 4 | 5 | **медиана** |
|---|---|---|---|---|---|---|
| seq read | 338 | 361 | 358 | 361 | 363 | **≈360 МБ/с** |
| seq write | 56.8 | 58.5 | 60.1 | 58.0 | 59.3 | **≈58.5 МБ/с** |
| rand read 4K, IOPS | 2306 | 2579 | 2573 | 2496 | 2522 | **≈2522** |
| rand write 4K, IOPS | 5240 | 5596 | 4931 | 5735 | 5563 | **≈5563** |

Аппаратно: `usb-storage` (BOT), `queue_depth=1`, `discard_max_bytes=0`
(**TRIM нет**), `04e8:6300`, USB3 5000 Мбит/с, порт 2-1. Первоначальные
цифры «~400/60» из обзора подтвердились по порядку величины.



**Ключевые выводы:**
- У SD последовательная запись всего **~4.3 МБ/с**, а p99 случайной записи
  **53 мс** — это и есть источник фризов под нагрузкой.
- AGI в честном O_DIRECT **лучше SD** для ОС: посл. запись 40 МБ/с против 4.3
  (**×9**), случайная запись p99 26–30 мс против 53 (стабильнее). Случайное
  чтение у SD чуть лучше (0.41 vs 0.76 мс), но это вторично.
- Смена USB-порта (2-1 → 2-2, оба на контроллере `usb2`, 5000 Мбит/с) дала
  прирост только по посл. чтению (98 → 128 МБ/с); запись без изменений.
- Узкое место AGI/SD — **случайные 4K-записи** (BOT, `queue_depth=1`, без
  TRIM): команды сериализуются, p99 в десятки мс. **Samsung здесь кардинально
  лучше**: p99 0.31 мс против 26–53 (в ~85–170 раз), ~5563 IOPS против
  189–377.
- **Samsung FIT Plus быстрее AGI везде**, и особенно в том, что критично для
  ОС: посл. чтение **+180 %** (360 vs 128), посл. запись **+47 %** (58.5 vs 39.7),
  случ. запись **×~29** (5563 vs 192 IOPS). При этом так же BOT/без TRIM.
  Это делает Samsung наиболее предпочтительным носителем (при прочих равных —
  см. критерий suspend в разделе 10.5).

## 2a. Бенчмарк системы: SD vs AGI (fio)

Полный сравнительный прогон (`system-bench.sh`, fio 3.41, `iodepth=1`,
`O_DIRECT`). Результаты: `~/macbook-suspend/results/bench-{SD,AGI-2}*.txt`.
Оба носителя — на одном USB3-контроллере (`usb2`, 5000 Мбит/с). Для AGI
указан **финальный прогон** — уже с применённым тюнингом (udev
`rotational=0`, `mq-deadline`, `read_ahead=1024`); он лучше первого на
записи (25→31.7 МБ/с) и mix (386→436 IOPS read).

| Тест | SD | AGI | Победитель |
|---|---|---|---|
| seq read 1M | 93.5 МБ/с | **126 МБ/с** | AGI |
| seq write 1M | **4.8 МБ/с** | **31.7 МБ/с** | **AGI (×6.6)** |
| rand read 4K | **2476 IOPS** | 1344 IOPS | SD |
| rand write 4K | **509 IOPS** | 300 IOPS | SD |
| mix 70/30 r/w | read 672 / write 289 | read 436 / write 191 | SD |
| **boot** | 1м 09.8с | **44.3с** (холодн.) / 47.4с | **AGI (−22…−25с)** |
| rg --files /nix/store | 83.3с | 96–206с* | SD |

\* `rg` зависит от фоновой нагрузки и размера store (файлов растёт с
поколениями) — не показатель носителя.

Разбор boot: SD `firmware 12.4 + loader 18.6 + kernel 0.8 + initrd 17.7 +
userspace 20.2`; AGI `firmware 3.1–3.4 + loader 4.0–6.3 + kernel 0.8 +
initrd 12.9–13.1 + userspace 23.6–23.8`. У AGI сильно быстрее
firmware/loader/initrd.

**Вывод:** AGI заметно лучше там, где важно для отзывчивости — **последо-
вательная запись (×6)** и **загрузка (−25с)**. SD чуть быстрее на случайных
4K (лучше FTL-контроллер карты), но это вторично: система и так не упирается
в random-4K. Для работы на этой машине **AGI предпочтительнее.**

## 2b. Suspend: почему SD крашил, а AGI работает (теперь в режиме deep/S3)

Root-FS на USB-устройстве **не переживает resume, если устройство
отваливается при выходе из сна**. Диагностика (логи в `~/macbook-suspend/results/`):

- **SD (Apple-ридер `05ac:8406`):** при resume `usb 2-3: USB disconnect` →
  `sd ... DID_ERROR` → `EXT4-fs error` → `Remounting filesystem read-only`
  → краш. Воспроизводилось и на `deep`, и на `s2idle`. Причина — **сам
  Apple Card Reader** сбрасывается при выходе из сна и не успевает
  переподключиться, пока ядро уже пишет на root.
- **AGI (флешка `24a9:205a`):** resume переживает и в `s2idle`, и в `deep`.
  Проверено: s2idle — 3+ цикла (79с, 23с, «ушёл с ноутбуком»);
  **deep (S3) — 3 цикла** (7.5 мин, 6 мин 11 с, короткий). В deep USB-контроллер
  реально переинициализируется, но `sda` поднимается заново штатно, root ext4
  остаётся `rw` — **ни одного `USB disconnect`/`DID_ERROR`/`EXT4 error`**.
- **Samsung FIT Plus (`04e8:6300`, текущий root):** deep (S3) тоже **работает**.
  Проверено: после загрузки `mem_sleep` = `s2idle [deep]` (выбор deep взят из
  `mem_sleep_default=deep`), сон даёт `ACPI: PM: ... sleep state S3`, после
  resume `boot_id` не менялся, root `rw`. Нюанс: если в момент предыдущей
  загрузки был подключён Apple-ридер (давал `usb 2-3: USB disconnect`), ядро
  могло выбрать `s2idle` вместо deep — без ридера deep выбирается штатно.

**Почему deep, а не s2idle:** прошивка заявляет S3
(`ACPI: PM: (supports S0 S3 S4 S5)`), и в S3 машина экономичнее по батарее
(CPU выключен, питание периферии снято), тогда как s2idle держит SoC в S0ix и
тратит больше. Для ноутбука это главное преимущество.

**Как переключить (важно):** `mem_sleep_default=deep` в `boot.kernelParams`.
В рантайме — только через `echo deep | sudo tee /sys/power/mem_sleep`
(простой `sudo echo deep > /sys/...` **не сработает**: редирект `>` делает
оболочка от юзера, а не sudo). Проверка, что удержалось: `grep '\[deep\]'`.

Аппаратные детали: контроллер `Intel Wildcat Point-LP xHCI` (`0000:00:14.0`)
сбрасывает USB при S3; Broadwell **без HWP**, поэтому `intel_pstate` passive.
s2idle на Broadwell требует S0ix; в логах `intel_pch_thermal: S0ix might fail`
(PCH 58°C > порога 50°C) — ещё один довод в пользу deep.

**Итог:** проблема suspend была в носителе (Apple-ридер), а не в режиме.
На AGI suspend работает в обоих режимах; текущий рабочий —
**`deep` (S3)**, `s2idle` оставлен как fallback. Тестовый скрипт:
`~/macbook-suspend/deep-test.sh`.

## 2c. Донастройка под AGI (научный процесс: одна правка → замер)

После переезда на быструю флешку часть «защит от медленной SD» стала лишней.
Проверяли по одному изменению с прогоном `system-bench.sh`. Важный урок
методики: **fio на этой флешке даёт разброс ±30%** на одном и том же
параметре (seq write 27–43 МБ/с), поэтому одиночный прогон ничего не решает —
где нужно, делали повторы.

| Правка | Решение | Обоснование |
|---|---|---|
| `fstrim.timer` вкл → выкл | **оставлено** | BOT, `discard_max_bytes=0`, TRIM нет — таймер бесполезен |
| `vm.swappiness` 60 → 150 | **оставлено** | zram-only, 4 ГБ; агрессивнее уходим в сжатый RAM. На fio не влияет (это память, не I/O) |
| `commit=30` → 60 | **оставлено** | реже журнал → меньше всплесков записи и износа |
| `dirty_bytes` 32M/8M → 64M/16M | **оставлено** | AGI пишет ×6 быстрее SD; крупные батчи выгоднее для qd=1 BOT |
| `read_ahead_kb` 1024 → 2048 | **откатано** | чистый тест (4 повтора, drop_caches, чередование): 1024 и 2048 идентичны, ~123 МБ/с. Оставили 1024 |
| Firefox-кэш tmpfs 512M → 384M | **оставлено** | покрывает дефолтный disk-кэш Firefox (~350M), приоритет — отзывчивость |
| `/var/tmp` tmpfs 512M → 256M | **оставлено** | пуст; меньший worst-case RAM |
| `/tmp` в zram `ram/4` | **оставлено** | сжатие, полезно для сборок |

Инструменты: `system-bench.sh` (fio + systemd-analyze + PSI + rg),
`writeback-bench.sh` (буферизованная запись / всплески writeback),
`readahead-test.sh` (чередующийся тест read_ahead со сбросом кэша).
Все — в `~/macbook-suspend/`.

## 2d. Swap, hibernate и suspend-then-hibernate (на будущее)

Здесь разобрано, зачем отключён дисковый swap, нужен ли он для hibernate и
как эти механизмы сосуществуют. Вывод: **рабочий своп — только zram;
дисковый `sda3` — исключительно под hibernate** (активируется вручную).

### 2d.1. Почему sda3 в `noauto` (диск-своп не активен в работе)

Дисковый своп на USB-флешке был **главным источником фризов** в SD-эпоху
(разделы 3–4: после отключения sda3 PSI I/O `full` упал с ~42 % до ~0.9 %,
load average 4.27 → 0.32). Рабочий своп полностью обеспечивает **zram
(=100 % RAM, сжатие ~2–3×)** плюс `vm.swappiness=150`. Возвращать sda3
в обычную работу — значит вернуть фризы. **Для текущего режима (deep) диск-своп
не нужен.**

### 2d.2. Hibernate требует ДИСКОВЫЙ swap

`hibernate` (S4) пишет образ RAM на swap-устройство. **zram не подходит**
(он сам в RAM — при выключении пропадёт). Нужен физический swap (`sda3`,
8.4 ГБ ≥ RAM 4 ГБ). Поэтому, если однажды понадобится hibernate,
**sda3 придётся активировать** — но только под него.

### 2d.3. Как swap и hibernate сосуществуют

| Режим | sda3 в работе | Поведение |
|---|---|---|
| **A: sda3 активен всегда** | да | hibernate «из коробки», но рабочий своп снова идёт на флешку → **фризы могут вернуться** |
| **B: sda3 только под hibernate** | нет | zram-only в работе (без фризов); sda3 включается лишь на время сна/гибернации |

**Рекомендуемый — режим B**, он и настроен сейчас (sda3 `noauto`, ручной
`swapon` перед гибернацией, `swapoff` после):

```bash
# вручную уйти в hibernate (образ RAM → sda3, затем полное выключение)
sudo swapon /dev/disk/by-uuid/d237160e-7b7a-436c-81c7-dc3451f2d789
systemctl hibernate
# после пробуждения вернуть zram-only:
sudo swapoff /dev/disk/by-uuid/d237160e-7b7a-436c-81c7-dc3451f2d789
```

Нюанс: `resume=/dev/sda3 resume_wait=10` уже прописаны в `boot.kernelParams`
и `boot.resumeDevice`, поэтому ядру есть откуда читать образ при загрузке.

### 2d.4. `suspend-then-hibernate` (на будущее)

**Как работает:** сначала уходит в **deep (S3)** — быстро и экономно; при
истечении таймера (`HibernateDelaySec`, обычно часы) система **сама
просыпается по RTC** (будильник в железе, батарею не тратит), проверяет
условия и, если надо, сбрасывает RAM на диск (hibernate) и выключается.
Это решает главную слабость чистого deep: **во сне заряд не опрашивается**
(CPU выключен, UPower/logind спят), и при разряде в ноль защита — только
аппаратная (EC), т.е. грязное выключение. Гибрид сохраняет состояние на диск
до этого.

**Что нужно, чтобы включить (не настроено):**
1. **Активировать sda3** (сейчас `noauto`) — причём для *автоматического*
   гибрида режима B «на лету» недостаточно: нужен либо постоянно активный
   swap (режим A), либо sleep-хук, делающий `swapon`/`swapoff` вокруг
   hibernate.
2. **Проверить S4-resume на USB** — ядро должно прочитать образ с `sda3`
   *до* монтирования root, а USB-контроллер после сна сбрасывается. При
   `resume_wait=10` может не хватить (флешка поднимается медленно). Это **не
   проверено** и является главным риском.
3. Смириться со **скоростью**: hibernate ~40 МБ/с записи → образ 4 ГБ
   (сожмётся до ~1.5–2 ГБ) пишется ~40–60 с, чтение при resume — минуту+.
4. Настроить `HibernateDelaySec` и `suspend-then-hibernate` в
   `systemd-suspend.service` / `services.logind`.

**Решение сейчас:** оставляем **чистый `deep` без изменений**. Разбор записан
на случай, если по факту использования начнутся проблемы с отключением
(внезапный разряд во сне, потеря работы). Тогда вернуться сюда и настроить
режим B + `suspend-then-hibernate`.

### 2d.5. Прочее: заряд и UPower

- Дефолтный UPower уже имеет `CriticalPowerAction=HybridSleep`, но hibernate
  не настроен, а `AllowRiskyCriticalPowerAction=false` → фактически страховки
  при низком заряде **нет** (действие не выполнится).
- Если/когда захочется чистое выключение при низком заряде (без hibernate):
  `services.upower.settings.CriticalPowerAction = "PowerOff"`. Это защищает
  **бодрствующую** работу; во сне заряд не опрашивается (защита — только EC).

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

## 5. Итоговый тюнинг (актуальное состояние конфига)

Файл: `hosts/nixos/MacBook-Air/configuration.nix`. Значения ниже — **текущие
на AGI** (после раздела 2c). В скобках — что было на SD, если менялось.

- **Запись:** `vm.dirty_bytes=64M` (на SD 32M), `dirty_background_bytes=16M`
  (8M), `dirty_expire_centisecs=1500`, `dirty_writeback_centisecs=300`.
- **Память:** `vm.swappiness=150` (на SD 60), `vm.vfs_cache_pressure=60`,
  `vm.page-cluster=0`.
- **zram swap = 100 % RAM** (память не резервируется).
- **sda3 → `noauto`**: диск-своп не активен в работе (свопимся только в zram),
  гибернация возможна вручную:
  `sudo swapon /dev/disk/by-uuid/d237160e-7b7a-436c-81c7-dc3451f2d789 && systemctl hibernate`.
  Подробный разбор swap/hibernate — раздел 2d.
- **earlyoom**: пороги 5 %/5 %, `--avoid` для Firefox/композитора,
  `--prefer` для компиляторов/установщиков. Страховка от «завис вместо OOM».
- **Изоляция сессии:** `app.slice` (терминалы/сборки/браузер)
  `MemoryHigh=2300M`, `CPUWeight=50`; `session.slice` (композитор niri)
  `CPUWeight=300`, `MemoryMin=200M`, `MemoryLow=400M`.
- **ФС/диск:** root `noatime,commit=60` (на SD 30); udev для обоих носителей
  (`05ac:8406` и `24a9:205a`): `rotational=0`, `read_ahead=1024`,
  `mq-deadline`. `/tmp` в zram (`ram/4`), `/var/tmp` tmpfs **256M**,
  кэш Firefox в tmpfs **384M** для `rusich` и `bunny`.
- **journald:** `persistent`, лимит 32 МБ (логи зависаний переживают ребут).
- **fstrim.timer:** **выключен** (TRIM нет). Раньше включался nixos-hardware.
- **Suspend:** `mem_sleep_default=deep` (S3; было s2idle), `usbcore.autosuspend=-1`,
  `usb-storage.delay_use=5`, `acpi_sleep=nonvs`. `fix-sd-reader` **удалён**
  (деавторизовал корневое USB-устройство → краш); вместо него безопасный
  sleep-hook `/etc/systemd/system-sleep/rescan-sd-reader.sh` (только rescan).
- **Термал:** `thermald` **выключен**, `mbpfan` — единственный (из nixos-hardware).

### CPU (Broadwell i5-5250U)

- **Нет HWP** → `intel_pstate` работает в `passive` (драйвер `intel_cpufreq`),
  governor `schedutil`. Как следствие, нет `energy_performance_preference` (EPP)
  и `platform_profile` — firmware профилей не даёт.
- **Профили PPD/Noctalia — НЕ декоративны, но работают частично.** Замерено
  (переключение профиля + сэмпл частот):
  - меняют **только `energy_perf_bias` (EPB)**: power-saver=**15**,
    balanced=**6**, performance=**0**;
  - **не трогают** governor (всегда `schedutil`), `min/max_perf_pct`,
    `no_turbo` (всё одинаково во всех профилях);
  - эффект виден **в простое**: ~**1567 МГц** (power-saver) против
    ~**1860 МГц** (performance), разница ~300 МГц;
  - **под полной нагрузкой разницы нет** — все упираются в 2500 МГц
    (там ограничивает не EPB, а мощностной/тепловой бюджет).
  - Вывод: профили дают умеренную экономию батареи в простое. Оставляем как
    есть; `intel_pstate=disable` + `acpi-cpufreq` ради «полноценных» профилей
    **не делаем** (потеря pstate-регуляторов ради косметики; CPU не узкое
    место — `cpu_some` max ~40 % под нагрузкой).

### Отдельно: парсер `gitcommit` (nvim)

`gbprod/tree-sitter-gitcommit` генерирует `parser.c` ~3.3 МБ; сборка пикует
**~3 ГБ** (`tree-sitter` CLI + `cc1`). На 4 ГБ вешает машину. Убран из
`ensure_installed` (`home/features/editors/neovim/config/lua/plugins/treesitter.lua`);
на мощных машинах ставить вручную: `:TSInstall gitcommit`.

## 6. Как воспроизвести замеры

Общее: перед случайными тестами нужен **writable** носитель с ФС, где
поддерживается `O_DIRECT` (ext4/f2fs). На iso9660/raw без root не выйдет —
именно поэтому ранние замеры AGI были буферизованными и недостоверными.

Подготовка флешки (ext4 без журнала, чтобы не мешал замерам). В системе нет
`parted` — используем `sfdisk` (размер раздела задать по своему носителю):

```bash
sudo umount /dev/sdX1 2>/dev/null
sudo wipefs -a /dev/sdX
sudo sfdisk /dev/sdX <<EOF
label: gpt
start=2048, size=<СЕКТОРЫ>, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="iobench"
EOF
sudo mkfs.ext4 -F -O ^has_journal -m 0 -L iobench /dev/sdX1
sudo mount -o noatime /dev/sdX1 /mnt/iobench
sudo chown $USER:users /mnt/iobench
```

```bash
# Тестовый файл 512 МиБ на измеряемом носителе (для чтения)
M=/mnt/iobench
dd if=/dev/zero of=$M/big bs=1M count=512 conv=fsync

# Последовательное чтение 512 МиБ (O_DIRECT)
dd if=$M/big of=/dev/null bs=1M iflag=direct count=512

# Случайное чтение 4K, O_DIRECT
python3 - "$M/big" <<'PY'
import os,time,random,mmap,sys
p=sys.argv[1]; size=os.path.getsize(p)
fd=os.open(p,os.O_RDONLY|os.O_DIRECT); m=mmap.mmap(-1,4096); mv=memoryview(m)
lat=[]; n=2000
for i in range(n):
    off=random.randrange(0,size-4096,4096)
    s=time.perf_counter(); os.preadv(fd,[mv],off); lat.append(time.perf_counter()-s)
del mv; os.close(fd); m.close(); lat.sort(); a=sum(lat)/n
print("avg=%.2fms p50=%.2f p95=%.2f p99=%.2f max=%.2f ~%.0f IOPS"%(a*1e3,lat[n//2]*1e3,lat[int(n*.95)]*1e3,lat[int(n*.99)]*1e3,lat[-1]*1e3,1000/(a*1e3)))
PY

# Случайная запись 4K, O_DIRECT (256 МиБ, n=2000, fsync в конце)
python3 - <<'PY'
import os,time,random,mmap
p="/mnt/iobench/rand"; size=256*1024*1024
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
dd if=/dev/zero of=$M/seq bs=1M count=256 conv=fsync

# PSI и память
cat /proc/pressure/io /proc/pressure/memory
free -h; swapon --show; zramctl
```

## 7. Чеклист сравнения новой флешки

1. Воткнуть, определить: `lsblk -o NAME,SIZE,TRAN,MODEL`;
   `readlink -f /sys/block/sdX/device/driver` → `usb-storage` (BOT) или `uas`.
2. `cat /sys/block/sdX/device/queue_depth` — 1 (BOT) или >1 (UAS).
3. `cat /sys/block/sdX/queue/discard_max_bytes` — есть ли TRIM.
4. Определить порт: `lsusb -t` и `readlink -f /sys/block/sdX/device` —
   на каком `usbN` контроллере и порту висит носитель.
5. Разметить (ext4/f2fs) и смонтировать в writable-точку (см. раздел 6).
6. Прогнать замеры из раздела 6, записать в таблицу (раздел 2).
7. Для сравнения «для ОС» важны: **посл. запись**, **случ. 4K запись (p99)**,
   `queue_depth`, TRIM. Посл. чтение — вторично.

## 8. Артефакты

- Скрипты и логи: `~/macbook-suspend/` (вне git-репо):
  - `system-bench.sh` — fio + systemd-analyze + PSI + rg; результат в `results/`.
  - `writeback-bench.sh` — буферизованная запись, всплески writeback/PSI.
  - `readahead-test.sh` — чередующийся read_ahead (нужен root, drop_caches).
  - `suspend-test.sh` — тест сна с внешним логом (переживает краш root);
    2-й аргумент — режим (`s2idle`/`deep`).
  - `deep-test.sh` — тест deep(S3) без внешнего носителя, лог в persistent
    journald; проверяет `boot_id` и `root rw` до/после, ставит/снимает deep.
  - `sync-to-flash.sh` / `watch-sync-to-flash.sh` — автосинк результатов на флешку.
  - `clone-1-format.sh`, `clone-2-rsync.sh`, `clone-3-bootloader.sh` — клон системы.
  - `results/` — `bench-SD-*.txt`, `bench-AGI-2-*.txt` (финальный),
    `baseline-AGI.txt`, `suspend-s2idle-AGI-works-*.log`.
- Сырой лог PSI-монитора: `/home/rusich/psi-monitor.log` (SD-эпоха).
- Ключевые коммиты (по порядку):
  - `2ef0955` первичный тюнинг SD; `7029dc5` память/своп/earlyoom/слайсы;
    `7447d96` gitcommit; `679cd10` честные O_DIRECT-замеры;
    `4c8606e` thermald off; `ce4d301` переезд на AGI + fix suspend;
    `21fd324` финальный бенчмарк AGI; `0cb3c02` fstrim off;
    `73de141` swappiness 150; `07f8a94` writeback-лимиты;
    `910f8b0` RAM-монтирования (кэш 384M, /var/tmp 256M); `424bd8c` раздел 2c.

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

## 10. Переезд на Samsung (СДЕЛАНО)

Samsung FIT Plus протестирован (раздел 2), выбран как новый носитель и
**система уже перенесена** на него: клонирование пофайлово (rsync) с теми же
UUID, systemd-boot в `EFI/BOOT` + `EFI/systemd`, AGI вынут. Samsung грузится,
udev-правило `04e8:6300` применилось, deep (S3) resume переживается.
Скрипты: `clone-new-1-format.sh`, `clone-new-2-rsync.sh`,
`clone-new-3-bootloader.sh` (определяют диски по **серийнику**, не по буквам).

### 10.1. Прежде чем что-либо трогать

1. Записать **текущий baseline AGI** (уже в `results/bench-AGI-2-*.txt`).
2. Перепроверить, что тесты делаются **на том же USB-порту** (2-2), иначе
   сравнение некорректно. `readlink -f /sys/block/sdX/device` → `.../2-2/...`.
3. Помнить: **fio-разброс ±30 %** на этих флешках — делать ≥2–3 прогона,
   брать лучший/медиану, не доверять одиночному числу.

### 10.2. Замер «сырого» носителя (СДЕЛАНО)

Samsung отформатирован как отдельный bench-носитель (`raw-bench.sh`: gpt +
ext4 без журнала, `mke2fs`), прогоны O_DIRECT сделаны на порту **2-1**.
Результаты — в разделе 2 (медианы 5 прогонов). Скрипты: `raw-bench.sh`
(формат + прогон) и `raw-repeat.sh` (повторные прогоны на смонтированном).

### 10.3. Перенос системы AGI → Samsung (клонирование)

Тем же способом, что SD → AGI (UUID совпадают, чтобы конфиг нашёл разделы):

- `clone-1-format.sh` — указывает на целевой носитель; разметка 1G EFI +
  root + swap 8G, те же UUID (`3122-0FD9`, `8302097e-…`, `d237160e-…`).
- `clone-2-rsync.sh` — пофайловое копирование `/` и `/boot`.
- `clone-3-bootloader.sh` — systemd-boot в `EFI/BOOT/BOOTX64.EFI` (fallback
  для Apple) + `EFI/systemd/`.
- **Важно:** скрипты рассчитаны на источник `sda` → цель `sdb`. При клоне
  AGI→Samsung источник — это AGI (`sda`), цель — Samsung; проверить буквы
  устройств и **размеры** (Samsung может быть меньше/больше — если меньше,
  старые `dd`-планы не годятся, используем rsync).

Порядок: загрузиться как обычно (AGI), воткнуть Samsung, прогнать 3 скрипта,
выключить, вынуть AGI, загрузиться с Samsung (Option → EFI Boot).

### 10.4. После переезда на Samsung

1. Проверить `rotational=0` для `24a9:…`? — нет, у Samsung **другой VID:PID** →
   добавить udev-правило под его `idVendor:idProduct`. Обновить `rescan-sd-reader`
   не нужно (он generic). Проверить `mem_sleep`/suspend (важнейший критерий —
   переживает ли resume, как AGI, или отваливается, как Apple-ридер).
2. Прогнать `system-bench.sh` на Samsung как root.
3. Сравнить: **посл. запись**, **rand 4K**, **boot**, **suspend**.

### 10.5. Критерии выбора

| Критерий | Вес |
|---|---|
| **Suspend переживает resume** | критично (иначе как SD — краш) |
| Посл. запись | высокий (влияет на отзывчивость) |
| Загрузка (boot) | высокий |
| Случ. 4K запись p99 | средний |
| Посл. чтение | низкий |

## 11. Шпаргалка текущего состояния (актуально на 2026-09-26)

- **Носитель:** **Samsung FIT Plus** (`04e8:6300`), root `/dev/sda2` (ext4),
  порт USB `2-2`. Был AGI (`24a9:205a`) — снят после переезда (раздел 10).
- **Загрузка:** штатная, без Option (systemd-boot в NVRAM).
- **Suspend:** **работает** в обоих режимах; активен **`deep` (S3)** —
  экономичнее по батарее. Проверено 3+ цикла deep и 3+ s2idle (включая
  «ушёл с ноутбуком, закрыл крышку»). Fallback — `s2idle`.
- **CPU:** Broadwell i5-5250U, pstate passive (`intel_cpufreq`)/schedutil (HWP нет).
  Профили PPD/Noctalia реально меняют лишь `energy_perf_bias` (EPB 15/6/0):
  ~300 МГц разницы **в простое**, под нагрузкой без разницы (раздел 5).
- **Термал:** mbpfan активен, thermald выключен.
- **Ребилд:** `sudo nixos-rebuild switch --flake ~/.dotfiles#MacBook-Air`.
- **Конфиг:** `hosts/nixos/MacBook-Air/configuration.nix` (все параметры — раздел 5).
- **Метрики/скрипты:** `~/macbook-suspend/` (+ `results/`).
- **Открытый план:** переезд на Samsung **выполнен** (раздел 10).
- **Задел на будущее:** если начнутся проблемы с отключением/разрядом во сне —
  вернуться к разделу **2d** (swap под hibernate, `suspend-then-hibernate`).
  Сейчас сознательно **чистый deep**, sda3 выключен (рабочий своп — zram).
- **Незакрытый вопрос:** Wi-Fi `wl` ворчит при resume (`WLAN scan error`),
  но сеть поднимается — при проблемах смотреть драйверы `wl`/`b43`.


