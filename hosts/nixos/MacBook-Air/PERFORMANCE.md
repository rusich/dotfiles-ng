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

## 0. Сводка: сравнение всех носителей

Все замеры — на одном USB3-контроллере (порт 2-2), `usb-storage` BOT,
`queue_depth=1`, без TRIM. Методика — O_DIRECT (раздел 2) и `system-bench.sh`
(раздел 2a). Медианы где применимо.

| Показатель | SD (Apple reader) | AGI (`24a9:205a`) | **Samsung FIT Plus** | Победитель |
|---|---|---|---|---|
| seq read | 93 МБ/с | 126 МБ/с | **370 МБ/с** | Samsung |
| seq write | 4.3 МБ/с | 32–42 МБ/с | **40–58 МБ/с** | Samsung |
| rand read 4K | 2450 IOPS | 1344 IOPS | **2743 IOPS** | Samsung |
| rand write 4K | 377–509 IOPS | 189–300 IOPS | **5563–6050 IOPS** | **Samsung (×20)** |
| rand write p99 | 53 мс | 26–30 мс | **0.31 мс** | Samsung (~100×) |
| boot | 70с | 44–47с | **40с** | Samsung |
| rg --files /nix/store | 83с | 96–206с | **~80с** (64–96) | нагрузко-зависим |
| suspend resume | **краш** | ок | **ок** | AGI/Samsung |

**Вывод:** Samsung быстрее всех и не крашит suspend → выбран. SD отвергнут
(посл. запись 4 МБ/с + краш при resume). AGI был рабочим, Samsung заменил его.
`rg` — не показатель носителя: зависит от кэша/нагрузки/размера store
(~785k файлов, 28 ГБ).

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

Проведено **5 прогонов** O_DIRECT (форматирование + замер, см. раздел 6),
порт **2-1**. Разброс маленький, цифры стабильны:

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
  см. критерий suspend в разделе 10.1).

## 2a. Бенчмарк системы: SD vs AGI vs Samsung (fio)

Полный сравнительный прогон (`system-bench.sh`, раздел 8.1; fio 3.41,
`iodepth=1`, `O_DIRECT`). Все носители — на одном USB3-контроллере
(`usb2`, 5000 Мбит/с), порт 2-2, с тюнингом (udev `rotational=0`,
`mq-deadline`, `read_ahead=1024`). Samsung тестировался на **своём корневом
ext4** (с журналом), SD/AGI — тоже на корневых ext4; поэтому seq write ниже,
чем в «сыром» тесте раздела 2.

| Тест | SD | AGI | **Samsung** | Победитель |
|---|---|---|---|---|
| seq read 1M | 93.5 МБ/с | 126 МБ/с | **370 МБ/с** | **Samsung** |
| seq write 1M | 4.8 МБ/с | 31.7 МБ/с | **40.3 МБ/с** | **Samsung** |
| rand read 4K | 2476 IOPS | 1344 IOPS | **2743 IOPS** | **Samsung** |
| rand write 4K | 509 IOPS | 300 IOPS | **6050 IOPS** | **Samsung (×20 vs AGI)** |
| mix 70/30 r/w | read 672 / write 289 | read 436 / write 191 | **read 564 / write 244** | Samsung (близко к SD) |
| **boot** | 1м 09.8с | 44.3с (холодн.) / 47.4с | **40.0с** | **Samsung** |
| rg --files /nix/store | 83.3с | 96–206с* | ~80с (64–96) | — |

\* `rg` зависит от фоновой нагрузки, кэша и размера store (~785k файлов,
28 ГБ) — не показатель носителя. Samsung на пустом кэше: 96с, повтор — 65с;
`rg --files --sort=path` (метаданные) — 79с; `rg -l` по содержимому — 2.5с.

Разбор boot: SD `firmware 12.4 + loader 18.6 + kernel 0.8 + initrd 17.7 +
userspace 20.2`; AGI `firmware 3.1–3.4 + loader 4.0–6.3 + kernel 0.8 +
initrd 12.9–13.1 + userspace 23.6–23.8`; Samsung `firmware 3.5 + loader 4.3 +
kernel 0.8 + initrd 12.8 + userspace 18.5`. У AGI/Samsung сильно быстрее
firmware/loader/initrd; у Samsung ещё и userspace (18.5 против 23.6).

**Вывод:** **Samsung лучше всех** по каждому показателю. Ключевое —
случайная запись **×20 к AGI** (6050 vs 300 IOPS) и посл. чтение **×2.9**
(370 vs 126). Именно random-4K был узким местом USB-носителей, и Samsung
его снимает. Boot быстрее AGI на ~4с, SD — на 30с.

## 2b. Suspend: почему SD крашил, а AGI работает (теперь в режиме deep/S3)

Root-FS на USB-устройстве **не переживает resume, если устройство
отваливается при выходе из сна**. Диагностика (по логам ядра):

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
На AGI/Samsung suspend работает в обоих режимах; текущий рабочий —
**`deep` (S3)**, `s2idle` оставлен как fallback. Тестовый скрипт — раздел 8.3.

## 2c. Донастройка под быструю флешку (научный процесс: одна правка → замер)

Первые правки проверялись на **AGI** (до переезда на Samsung); все они
унаследованы текущей системой. После переезда на быструю флешку часть
«защит от медленной SD» стала лишней.
Проверяли по одному изменению с прогоном `system-bench.sh`. Важный урок
методики: **fio на этой флешке даёт разброс ±30%** на одном и том же
параметре (seq write 27–43 МБ/с), поэтому одиночный прогон ничего не решает —
где нужно, делали повторы.

| Правка | Решение | Обоснование |
|---|---|---|
| `fstrim.timer` вкл → выкл | **оставлено** | BOT, `discard_max_bytes=0`, TRIM нет — таймер бесполезен |
| `vm.swappiness` 60 → 150 | **оставлено** | zram-only, 4 ГБ; агрессивнее уходим в сжатый RAM. На fio не влияет (это память, не I/O) |
| `commit=30` → 60 | **оставлено** | реже журнал → меньше всплесков записи и износа |
| `dirty_bytes` 32M/8M → 64M/16M | **оставлено** | быстрая флешка пишет ×6+ быстрее SD; крупные батчи выгоднее для qd=1 BOT |
| `read_ahead_kb` 1024 → 2048 | **откатано** | чистый тест (4 повтора, drop_caches, чередование): 1024 и 2048 идентичны, ~123 МБ/с. Оставили 1024 |
| Firefox-кэш tmpfs 512M → 384M | **оставлено** | покрывает дефолтный disk-кэш Firefox (~350M), приоритет — отзывчивость |
| `/var/tmp` tmpfs 512M → 256M | **оставлено** | пуст; меньший worst-case RAM |
| `/tmp` в zram `ram/4` | **оставлено** | сжатие, полезно для сборок |

Инструменты: `system-bench.sh` (раздел 8.1: fio + systemd-analyze + PSI + rg).
`writeback-bench.sh` и `readahead-test.sh` использовались в этой серии
экспериментов и удалены вместе с системой (при необходимости воспроизводимы
по разделу 6).

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
+ ~20 mason-пакетов. По логу PSI-монитора (раздел 9):

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
на Samsung**. В скобках — что было на SD, если менялось.

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
- **ФС/диск:** root `noatime,commit=60` (на SD 30); udev по VID:PID для всех
  носителей (Apple `05ac:8406`, AGI `24a9:205a`, Samsung `04e8:6300`):
  `rotational=0`, `read_ahead=1024`, `mq-deadline`. `/tmp` в zram (`ram/4`),
  `/var/tmp` tmpfs **256M**, кэш Firefox в tmpfs **384M** для `rusich` и `bunny`.
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

> **Примечание:** система на этом ноутбуке будет переустановлена, поэтому
> каталог `~/macbook-suspend/` со скриптами и логами удалён; его содержимое
> либо уже отражено в этом документе, либо не критично. Ключевые готовые
> скрипты встроены ниже (разделы 8.1–8.3), чтобы их можно было пересоздать.

- Ключевые коммиты в истории репозитория:
  - `2ef0955` первичный тюнинг SD; `7029dc5` память/своп/earlyoom/слайсы;
    `7447d96` gitcommit; `679cd10` честные O_DIRECT-замеры;
    `4c8606e` thermald off; `ce4d301` переезд на AGI + fix suspend;
    `21fd324` финальный бенчмарк AGI; `0cb3c02` fstrim off;
    `73de141` swappiness 150; `07f8a94` writeback-лимиты;
    `910f8b0` RAM-монтирования; `424bd8c` раздел 2c; `db59b0d` Broadcom wl;
    `265573d` чистка GNOME; `f761bee` замеры Samsung;
    `fe68a98` переезд на Samsung; `5b375d1` Samsung в системе.
- **Воспроизведение замеров** — команды в разделе 6 (базовые O_DIRECT) и
  скрипт `system-bench.sh` ниже (раздел 8.1).

### 8.1. `system-bench.sh` — объективный бенчмарк носителя/системы

```sh
#!/bin/sh
# Использование: system-bench.sh <каталог-на-носителе> [метка]
# Требует: fio, systemd-analyze, rg. Запускать под пользователем.
set -e
TESTDIR="${1:?Укажи каталог на носителе, напр. /mnt/iobench}"
LABEL="${2:-$(basename "$TESTDIR")}"
FIO=$(command -v fio || echo fio)
OUT="$HOME/bench-${LABEL}-$(date +%Y%m%d-%H%M%S).txt"
mkdir -p "$TESTDIR"; TESTFILE="${TESTDIR}/fio-testfile"; SIZE=512M

sep() { printf '\n===== %s =====\n' "$1" | tee -a "$OUT"; }
psi() { awk '/^some/{s=$2} /^full/{f=$2} END{printf "io: some=%s full=%s\n", s, f}' /proc/pressure/io; }

{ echo "######## SYSTEM BENCH ########"
  echo "date:    $(date -Is)"
  echo "label:   $LABEL"
  echo "root:    $(findmnt -no SOURCE,FSTYPE /)"
  echo "fio:     $($FIO --version)"
} | tee "$OUT"

sep "1a. fio: посл. чтение (O_DIRECT, qd=1)"
$FIO --name=seq-read  --filename="$TESTFILE" --size=$SIZE --rw=read     --bs=1M --direct=1 --iodepth=1 --ioengine=psync 2>&1 | tee -a "$OUT"
sep "1b. fio: посл. запись (O_DIRECT, qd=1, fsync)"
$FIO --name=seq-write --filename="$TESTFILE" --size=$SIZE --rw=write    --bs=1M --direct=1 --iodepth=1 --ioengine=psync --fsync=1 2>&1 | tee -a "$OUT"
sep "1c. fio: случ. чтение 4K (O_DIRECT, qd=1)"
$FIO --name=rand-read --filename="$TESTFILE" --size=$SIZE --rw=randread --bs=4k --direct=1 --iodepth=1 --ioengine=psync --runtime=15 --time_based=1 2>&1 | tee -a "$OUT"
sep "1d. fio: случ. запись 4K (O_DIRECT, qd=1)"
$FIO --name=rand-write --filename="$TESTFILE" --size=$SIZE --rw=randwrite --bs=4k --direct=1 --iodepth=1 --ioengine=psync --runtime=15 --time_based=1 2>&1 | tee -a "$OUT"
sep "1e. fio: mix 70/30 r/w 4K (qd=1)"
$FIO --name=mix7030 --filename="$TESTFILE" --size=$SIZE --rw=randrw --rwmixread=70 --bs=4k --direct=1 --iodepth=1 --ioengine=psync --runtime=15 --time_based=1 2>&1 | tee -a "$OUT"
rm -f "$TESTFILE"

sep "2. systemd-analyze"; systemd-analyze 2>&1 | tee -a "$OUT"
systemd-analyze blame 2>&1 | head -15 | tee -a "$OUT"

sep "3. PSI под нагрузкой"; echo "до: $(psi)" | tee -a "$OUT"
$FIO --name=psi --filename="${TESTDIR}/psi-tmp" --size=256M --rw=randrw --bs=4k --direct=1 --iodepth=1 --ioengine=psync --runtime=10 --time_based=1 >/dev/null 2>&1 &
F=$!; sleep 2; for i in 1 2 3 4; do echo "t=$i: $(psi)" | tee -a "$OUT"; sleep 2; done
wait $F 2>/dev/null || true; rm -f "${TESTDIR}/psi-tmp"; echo "после: $(psi)" | tee -a "$OUT"

sep "4. rg --files /nix/store (metadata-heavy)"
t0=$(date +%s%N); N=$(rg --files /nix/store 2>/dev/null | wc -l); t1=$(date +%s%N)
echo "файлов: $N, время: $(( (t1-t0)/1000000 )) ms" | tee -a "$OUT"
t0=$(date +%s%N); rg -m20 -l "GNU General Public" /nix/store --no-messages 2>/dev/null | head -20 >/dev/null; t1=$(date +%s%N)
echo "rg -l по содержимому: $(( (t1-t0)/1000000 )) ms" | tee -a "$OUT"

sep "ГОТОВО"; echo "Результат: $OUT"
```

### 8.2. `raw-bench.sh` — «сырой» замер носителя (O_DIRECT)

Полный текст — по образцу раздела 6; ключевое: разметить ext4 **без журнала**,
смонтировать, затем прогнать seq read 512M, seq write 256M (fsync),
случ. 4K чтение/запись (n=2000, p50/p95/p99). Разметку делать `sfdisk`
(`parted` в системе нет), `size=$((SECTORS-4096))` (оставить запас под GPT).

### 8.3. `deep-test.sh` — проверка deep(S3) без внешнего носителя

```sh
#!/bin/sh
# Запускать под sudo. Лог — в persistent journald (переживёт краш root).
set -e
WAIT="${1:-5}"
MARKER="DEEPTEST-$(date +%Y%m%d-%H%M%S)-$$"
echo "marker=$MARKER"; echo "root: $(findmnt -no SOURCE /)"
echo deep > /sys/power/mem_sleep
grep -q '\[deep\]' /sys/power/mem_sleep || { echo "deep не удержался"; exit 1; }
logger -t deep-test "$MARKER BEFORE boot_id=$(cat /proc/sys/kernel/random/boot_id)"
sync; sleep "$WAIT"; systemctl suspend
logger -t deep-test "$MARKER AFTER root=$(findmnt -no SOURCE /) boot_id=$(cat /proc/sys/kernel/random/boot_id)"
echo "resumed: $(findmnt -no SOURCE,FSTYPE,OPTIONS /)"
# Проверки: journalctl -k -b 0 | grep -E 'suspend entry|sleep state S3'
#           journalctl -t deep-test | tail   (должны быть BEFORE и AFTER)
```

## 9. Приложение: скрипт монитора PSI (справочно)

Скрипт использовался для записи PSI/памяти во время тяжёлых тестов (раздел 4)
и лёг в основу выводов о memory-pressure. Лог и сам файл удалены вместе с
системой. Запуск был: `setsid nohup ./psi-monitor.sh >/dev/null 2>&1 &`,
остановка: `pkill -f psi-monitor.sh`. При необходимости пересоздать из текста:

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

## 10. Переезд на Samsung — отчёт

Samsung FIT Plus протестирован (разделы 2, 2a), выбран вместо AGI и система
**перенесена** на него. Как это делалось (для повторения в будущем):

1. **Разметка + ФС** на Samsung с **теми же UUID**, что у AGI (чтобы
   `hardware-configuration.nix`/fstab нашли разделы без правок):
   - boot vfat `3122-0FD9` (1G EFI), root ext4 `8302097e-…`, swap `d237160e-…` (8G).
   - `mkfs.vfat -i 31220FD9`, `mkfs.ext4 -U <uuid>`, `mkswap -U <uuid>`.
   - Разметка `sfdisk` (GPT; `parted` в системе нет).
2. **rsync** `/` и `/boot` на новый root (исключая `/boot`, `/proc`, `/sys`,
   `/dev`, `/run`, `/tmp`, `/mnt`, `/media`, `/var/tmp`, кэш Firefox).
3. **systemd-boot**: `EFI/BOOT/BOOTX64.EFI` (fallback для Apple) +
   `EFI/systemd/systemd-bootx64.efi` (+ `loader/entries` из `/boot`).
4. Выключить, **вынуть AGI**, загрузиться с Samsung (Option → EFI Boot).
5. Пост-проверки: `findmnt /` = Samsung `sda2`; udev (`rotational=0`,
   `read_ahead=1024`, `mq-deadline`); `mem_sleep_default=deep` в cmdline;
   suspend (deep/S3) переживает resume.

**Важные уроки:**
- Устройства в скриптах клонирования лучше искать **по серийнику/VID:PID**, а
  не по `sda`/`sdb` — буквы плавают. Samsung: `04e8:6300` /
  serial `0374525090001858`; AGI: `24a9:205a` / `AGIUME0657547`. UUID у носителей
  намеренно **совпадают**, иначе система не найдёт root.
- Для новой флешки на будущее: критерии выбора — ниже.

### 10.1. Критерии выбора носителя (по важности)

| Критерий | Вес |
|---|---|
| **Suspend переживает resume** | критично (иначе как SD — краш) |
| Случ. 4K запись (p99) | высокий (узкое место USB) |
| Посл. запись | высокий |
| Загрузка (boot) | средний |
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
- **Скрипты замеров:** встроены в документ (раздел 8); отдельного каталога нет.
- **Открытый план:** переезд на Samsung **выполнен** (раздел 10).
- **Задел на будущее:** если начнутся проблемы с отключением/разрядом во сне —
  вернуться к разделу **2d** (swap под hibernate, `suspend-then-hibernate`).
  Сейчас сознательно **чистый deep**, sda3 выключен (рабочий своп — zram).
- **Незакрытый вопрос:** Wi-Fi `wl` ворчит при resume (`WLAN scan error`),
  но сеть поднимается — при проблемах смотреть драйверы `wl`/`b43`.


