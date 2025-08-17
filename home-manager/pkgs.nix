{ config, pkgs, system, userSettings, unstable, inputs, ... }: {
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    mdcat # pretty md print
    unstable.opencode
    xdg-user-dirs
    playerctl
    neofetch
    fastfetch
    microfetch
    breeze-hacked-cursor-theme
    whitesur-gtk-theme
    whitesur-icon-theme
    nwg-look
    libsecret
    gnome-calculator
    cht-sh
    wl-clipboard
    luarocks
    rustup
    rofi-wayland
    wofi
    swaynotificationcenter
    waybar
    waylock
    libnotify
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term # neovim
    nerd-fonts.fantasque-sans-mono # waybar
    ripgrep
    fzf
    delta
    jq
    wlogout
    hyprlock
    hypridle
    wpaperd
    blueman
    pamixer
    pavucontrol
    keepassxc
    nodejs_24 # for neovim
    nextcloud-client
    yazi
    ncdu
    nautilus
    nautilus-python # nextcloud integration
    nautilus-open-any-terminal
    fd
    eza
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    networkmanagerapplet
    # cowsay

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
}
