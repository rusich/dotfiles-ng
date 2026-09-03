{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.my.nixosModules.ollama.enable = lib.mkEnableOption "ollama service with open-webui";

  config = lib.mkIf config.my.nixosModules.ollama.enable {
    users.users.ollama = {
      isSystemUser = true;
      extraGroups = [
        "video"
        "render"
      ];
      home = "/home/ollama";
      createHome = true; # чтобы NixOS создал директорию с правильными правами
    };

    services.ollama = {
      enable = true;
      package = pkgs.unstable.ollama-rocm;
      user = "ollama";
      group = "users";
      home = "/home/ollama"; # явно указываем
      environmentVariables = {
        # OLLAMA_CONTEXT_LENGTH = "65536";
        OLLAMA_CONTEXT_LENGTH = "131072";
        # OLLAMA_CONTEXT_LENGTH = "262144";
        OLLAMA_FLASH_ATTENTION = "1";
      };
    };

    systemd.services.ollama.serviceConfig = {
      ProtectHome = lib.mkForce false;
    };

    services.open-webui.enable = true;

    # Если нужно установить права для группы users (рекурсивно g+rwx и setgid)
    system.activationScripts.setupOllamaDir = {
      text = ''
        mkdir -p /home/ollama
        chown -R ollama:users /home/ollama
        chmod -R g+rwx /home/ollama
        chmod g+s /home/ollama
      '';
      deps = [ ];
    };
  };
}
