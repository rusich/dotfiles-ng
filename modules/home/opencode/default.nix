{
  config,
  pkgs,
  hostname,
  lib,
  ...
}:
let
  # Общая логика: пароль и имя пользователя хаба извлекаются из KeePassXC
  # (Secret Service) в рантайме через secret-tool. Ждём разблокировки базы
  # (retry-цикл), т.к. сервис может стартовать раньше KeePassXC.
  fetchHubCreds = ''
    PASS=""
    USERNAME=""
    for _ in $(seq 1 60); do
      [ -n "$PASS" ] || PASS="$(${pkgs.libsecret}/bin/secret-tool lookup short OPENCODE_SERVER_PASSWORD 2>/dev/null)"
      [ -n "$USERNAME" ] || USERNAME="$(${pkgs.libsecret}/bin/secret-tool lookup short OPENCODE_SERVER_USERNAME 2>/dev/null)"
      [ -n "$PASS" ] && [ -n "$USERNAME" ] && break
      sleep 2
    done
    if [ -z "$PASS" ]; then
      echo "opencode: OPENCODE_SERVER_PASSWORD unavailable via secret-tool" >&2
      exit 1
    fi
    export OPENCODE_SERVER_PASSWORD="$PASS"
    export OPENCODE_SERVER_USERNAME="''${USERNAME:-opencode}"
  '';

  # Служба-хаб: headless сервер для веб-UI (телефон через traefik), защищён
  # basic auth (см. fetchHubCreds). Порт задан в конфиге
  # (programs.opencode.settings.server.port = 4096), а НЕ флагом `--port`: так
  # opencode.nvim и `oc` (ищут процессы по `opencode.*--port` через pgrep) не
  # видят хаб и не путают его с инстансами проектов.
  opencode-web = pkgs.writeShellScript "opencode-web" ''
    ${fetchHubCreds}
    exec ${config.programs.opencode.package}/bin/opencode serve --hostname 0.0.0.0
  '';

  # oc: вход в opencode для текущего проекта. Каждый проект — свой инстанс на
  # случайном свободном порту (чистая README-модель opencode.nvim). Логика:
  #   1) ищем запущенный opencode-сервер этого каталога — как это делает сам
  #      плагин: pgrep `opencode.*--port` → lsof → GET /path → сравнить directory;
  #   2) нашли  — attach к нему (сессии общие: nvim-плагин, snacks-TUI и
  #      отдельные окна одного проекта работают вместе);
  #   3) нет    — поднимаем свой инстанс: `opencode --port 0 <project>`.
  oc = pkgs.writeShellScriptBin "oc" ''
    TARGET="$PWD"
    PORT=""
    for pid in $(pgrep -f '[o]pencode.*--port' 2>/dev/null); do
      for p in $(lsof -a -P -n -iTCP -sTCP:LISTEN -p "$pid" -F n 2>/dev/null | sed -n 's/^n.*:\([0-9][0-9]*\)$/\1/p' | sort -u); do
        dir=$(curl -s --max-time 2 "http://localhost:$p/path" 2>/dev/null | sed -n 's/.*"directory":"\([^"]*\)".*/\1/p')
        if [ -n "$dir" ] && { [ "$TARGET" = "$dir" ] || [ ''${TARGET#$dir/} != "$TARGET" ] || [ ''${dir#$TARGET/} != "$dir" ]; }; then
          PORT="$p"
          break 2
        fi
      done
    done
    if [ -n "$PORT" ]; then
      exec ${config.programs.opencode.package}/bin/opencode attach "http://localhost:$PORT" --dir "$TARGET" "$@"
    else
      exec ${config.programs.opencode.package}/bin/opencode --port 0 "$TARGET" "$@"
    fi
  '';
in
{
  home.packages = with pkgs; [
    lsof
    curl
    procps # для pgrep (opencode.nvim и `oc` ищут сервер через pgrep/lsof)
    oc
  ];

  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
    settings = {
      # Порт хаба для веб-UI (traefik → 4096). На инстансы проектов не влияет:
      # те запускаются с явным `--port 0` (случайный свободный порт).
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          options = {
            baseURL = "http://127.0.0.1:11434/v1";
          };

          models = {
            "qwen3.8:27b" = {
              name = "Qwen 3.8 27B (local)";
              tools = true;
              limit = {
                context = 65536;
                output = 32768;
              };
            };
            "qwen3-coder:30b" = {
              name = "Qwen 3 Coder 30B (local)";
              tools = true;
              limit = {
                context = 65536;
                output = 32768;
              };
            };

          };

        };
      };
      server = {
        port = 4096;
      };
      permission = {
        edit = "ask";
        external_directory = {
          "*" = "ask";
          "/tmp/**" = "allow";
        };
      };
      # Railway MCP: подключается через Railway CLI (railway mcp) и использует
      # авторизацию `railway login`. CLI установлен через npm в ~/.local/bin
      # (nixpkgs-версия 5.30.4 < требуемых 5.44.0). Когда nixpkgs обновится до
      # >= 5.44.0 — заменить на pkgs.railway и путь "railway".
      mcp = {
        railway = {
          type = "local";
          command = [
            "/home/rusich/.local/bin/railway"
            "mcp"
          ];
          enabled = false;
        };
      };
    };
  };

  # Конфиги и скиллы из дотфайлов → стандартные места в домашней директории.
  # Скиллы мапятся в общую папку агентов (её видит и opencode, и другие агенты).
  home.file = {
    ".agents/skills".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/opencode/skills";
  };

  # Постоянный хаб для веб-UI: к нему ходит traefik (телефон). Сессии nvim/TUI
  # живут на инстансах проектов (см. oc) и с вебом не общие. Включается только
  # на darkstar (hostname прокидывается из flake.nix через extraSpecialArgs).
  systemd.user.services.opencode-web = lib.mkIf (hostname == "darkstar") {
    Unit = {
      Description = "opencode server (web UI for phone via traefik)";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${opencode-web}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
