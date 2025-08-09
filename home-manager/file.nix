# Dotfile overrides with write permissions (instead of using `stow`)
{ config, pkgs, userSettings, ... }: {
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/mimeapps.list".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/mimeapps.list";
    # Old dotfiles wrapping with home-manager (instead manually using `stow`)
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/nvim";
    # ".config/bat".source = config.lib.file.mkOutOfStoreSymlink
    #   "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/bat";
    # ".config/delta".source = config.lib.file.mkOutOfStoreSymlink
    # "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/delta";
    # ".config/fish".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/fish";
    # ".config/git".source = config.lib.file.mkOutOfStoreSymlink
    #   "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/git";
    # ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink
    #   "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/hypr";
    ".config/keepassxc".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/keepassxc";
    ".config/kitty".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/kitty";
    # ".config/rofi".source = config.lib.file.mkOutOfStoreSymlink
    #   "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/rofi";
    # ".config/waybar".source = config.lib.file.mkOutOfStoreSymlink
    #   "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/waybar";
    # ".config/wlogout".source = config.lib.file.mkOutOfStoreSymlink
    #   "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/wlogout";
    # ".config/wpaperd".source = config.lib.file.mkOutOfStoreSymlink
    #   "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/wpaperd";
    ".editorconfig".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/home/editorconfig";
    # ".config/avizo".source = config.lib.file.mkOutOfStoreSymlink
    #   "${config.home.homeDirectory}/.dotfiles/home-manager/dotfiles/avizo";

    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    # ".config/home-manager/home.nix".source = ./home.nix;
  };
}
