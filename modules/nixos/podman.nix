{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:
let
  cfg = config.my.nixosModules.podman;
in
{
  options = {
    my.nixosModules.podman.enable = lib.mkEnableOption "Podman with Docker compatibility (docker CLI alias and /run/docker.sock)";
  };

  config = lib.mkIf cfg.enable {
    # ============================================
    # PODMAN (с эмуляцией Docker)
    # CLI-совместимость: команда `docker` -> podman,
    # сокет /run/docker.sock для docker-клиентов (lazydocker и т.п.)
    # ============================================

    virtualisation.podman = {
      enable = true;
      dockerCompat = true; # алиас docker -> podman
      dockerSocket.enable = true; # симлинк /run/docker.sock -> podman socket
      defaultNetwork.settings.dns_enabled = true; # DNS между контейнерами (aardvark-dns)
      extraPackages = [
        pkgs.slirp4netns # сеть для rootless-контейнеров
        pkgs.docker-compose
      ];
    };

    # Глушим warning podman при использовании docker-compose
    virtualisation.containers.containersConf.settings.engine.compose_warning_logs = false;

    environment.systemPackages = with pkgs; [
      lazydocker
    ];

    # Сокет podman создаётся с группой "podman" (SocketGroup), симлинк
    # /run/docker.sock не поддерживает другую группу, поэтому пользователя
    # добавляем именно в "podman", а не "docker"
    users.users.${userConfig.username}.extraGroups = [ "podman" ];
  };
}
