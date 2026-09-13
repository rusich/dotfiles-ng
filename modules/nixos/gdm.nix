{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.nixos.profiles.gdm;
in
{
  options = {
    nixos.profiles.gdm.enable = lib.mkEnableOption "Enable GMD display manager with some useful augmentations";
  };

  config = lib.mkIf cfg.enable {

    # DISPLQAY MANAGER

    environment.systemPackages = with pkgs; [
      gdm-settings
      acl
    ];

    # GDM
    services.displayManager.gdm = {
      enable = true;
    };

    # GDM augmentations

    # Доступ к /home/<username>/.face
    systemd.services.gdm-setup-acl = {
      description = "Set ACL permissions for GDM access to user directories";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      before = [ "display-manager.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "gdm-acl-setup" ''
          # Устанавливаем права на КОРНЕВЫЕ домашние папки (без -R!)
          for dir in /home/*/; do
            if [ -d "$dir" ]; then
              # Нормализуем путь (убираем trailing slash)
              dir="''${dir%/}"
              # Даем группе gdm право на выполнение (x) только для КОРНЕВОЙ папки
              ${pkgs.acl}/bin/setfacl -m group:gdm:x "$dir"
              # Даем группе gdm права на чтение и выполнение для .face файлов.
              # Симлинки (например, в /nix/store) пропускаем: setfacl по цели
              # на read-only store упал бы, а store-файлы и так world-readable.
              for face_file in "$dir/.face" "$dir/.face.icon" "$dir/.icon"; do
                if [ -e "$face_file" ] && [ ! -L "$face_file" ]; then
                  ${pkgs.acl}/bin/setfacl -m group:gdm:rx "$face_file"
                fi
              done
            fi
          done
        '';
      };
    };

    # Доступ к /home/<username>/.face (запуск при выходе из сеанса пользователя)
    systemd.user.services.gdm-acl-on-logout = {
      description = "Set GDM ACL permissions on logout";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Просто запускаем и сразу завершаемся
        ExecStart = "${pkgs.coreutils}/bin/true";
        # Этот скрипт выполнится при остановке graphical-session.target
        ExecStopPost = pkgs.writeShellScript "gdm-acl-logout" ''
          if [ -d "$HOME" ]; then
            echo "[$(date)] Setting GDM ACL for $USER on logout" | logger -t gdm-acl
            # Даем GDM доступ к домашней папке
            ${pkgs.acl}/bin/setfacl -m group:gdm:x "$HOME"
            # И к файлам аватарок (симлинки в store пропускаем, см. выше)
            for face_file in "$HOME/.face" "$HOME/.face.icon" "$HOME/.icon"; do
              if [ -e "$face_file" ] && [ ! -L "$face_file" ]; then
                ${pkgs.acl}/bin/setfacl -m group:gdm:rx "$face_file"
              fi
            done
          fi
        '';
      };
    };
  };
}
