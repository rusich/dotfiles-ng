{ config, pkgs, ... }:
let
  # Wrapper: пароль сервера извлекается из KeePassXC (Secret Service) в
  # рантайме через secret-tool. Ждём разблокировки базы (retry-цикл),
  # т.к. сервис может стартовать раньше KeePassXC.
  opencode-web = pkgs.writeShellScript "opencode-web" ''
    PASS=""
    for _ in $(seq 1 60); do
      PASS="$(${pkgs.libsecret}/bin/secret-tool lookup short OPENCODE_SERVER_PASSWORD 2>/dev/null)" \
        && [ -n "$PASS" ] && break
      sleep 2
    done
    if [ -z "$PASS" ]; then
      echo "opencode-web: OPENCODE_SERVER_PASSWORD unavailable via secret-tool" >&2
      exit 1
    fi
    export OPENCODE_SERVER_PASSWORD="$PASS"
    export BROWSER=true # не открывать браузер под systemd
    exec ${config.programs.opencode.package}/bin/opencode web --port 4096 --hostname 0.0.0.0
  '';
in
{
  home.packages = with pkgs; [
    lsof
    curl
    procps # for pgrep dependency
  ];

  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
    # agents = {
    # };
  };

  # Постоянный хаб: к нему подключаются TUI (opencode attach), веб-UI
  # (телефон через traefik) и neovim-плагин. Сессии хранятся на сервере.
  systemd.user.services.opencode-web = {
    Unit = {
      Description = "opencode web server (hub for TUI/web/neovim clients)";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${opencode-web}/bin/opencode-web";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
