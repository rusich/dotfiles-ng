{ config, pkgs, ... }:
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

  # Служба-хаб: headless сервер, отдаёт тот же HTTP-API и веб-UI, но не открывает браузер.
  opencode-web = pkgs.writeShellScript "opencode-web" ''
    ${fetchHubCreds}
    exec ${config.programs.opencode.package}/bin/opencode serve --port 4096 --hostname 0.0.0.0
  '';

  # oc: TUI-клиент, подключающийся к хабу с авторизацией из KeePassXC.
  # Проект = текущий каталог (поддержка нескольких проектов на одном хабе).
  oc = pkgs.writeShellScriptBin "oc" ''
    ${fetchHubCreds}
    exec ${config.programs.opencode.package}/bin/opencode attach http://localhost:4096 --dir "$PWD" "$@"
  '';
in
{
  home.packages = with pkgs; [
    lsof
    curl
    procps # for pgrep dependency
    oc
  ];

  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
    settings = {
      permission = {
        edit = "ask";
      };
    };
    # agents = {
    # };
  };

  # Постоянный хаб: к нему подключаются TUI (opencode attach), веб-UI
  # (телефон через traefik) и neovim-плагин. Сессии хранятся на сервере.
  systemd.user.services.opencode-web = {
    Unit = {
      Description = "opencode server (hub for TUI/web/neovim clients)";
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
