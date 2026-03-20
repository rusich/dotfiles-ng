{ pkgs, ... }:
{
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
            # Даем группе gdm права на чтение и выполнение для .face файла
            # Альтернативные файлы аватарок
            for face_file in "/home/$USER/.face.icon" "/home/$USER/.icon"; do
              if [ -e "$face_file" ]; then
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
          # И к файлам аватарок
          for face_file in "$HOME/.face" "$HOME/.face.icon" "$HOME/.icon"; do
            if [ -e "$face_file" ]; then
              ${pkgs.acl}/bin/setfacl -m group:gdm:rx "$face_file"
            fi
          done
        fi
      '';
    };
  };
}
