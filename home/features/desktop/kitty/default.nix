{ config, ... }: {
  home.file = {
    ".config/kitty".source =
      config.lib.file.mkOutOfStoreSymlink config.homeModulesPath + "/features/desktop/kitty/config";
  };

  # Настройка dconf для GNOME (установка kitty как терминала по умолчанию)
  dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "kitty";
      exec-arg = "-e";
    };
  };

  # Создаём .desktop-запись для запуска Neovim в kitty (GUI-редактор без терминала)
  # Стандартный nvim.desktop перезаписывается, иначе nvim открывался бы в эмуляторе по умолчанию
  xdg.dataFile."applications/nvim.desktop".text = ''
    [Desktop Entry]
    Name=Neovim (Kitty)
    GenericName=Text Editor
    Comment=Edit text files in Kitty terminal
    TryExec=nvim
    Exec=kitty --class=neovim -e nvim %F
    Terminal=false
    Type=Application
    Icon=nvim
    Categories=Utility;TextEditor;
    StartupNotify=false
    MimeType=application/sql;text/x-sql;text/plain;
    Keywords=Text;editor;
  '';
}
