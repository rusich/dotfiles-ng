{
  pkgs,
  config,
  userConfig,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neovim
    alacritty
    mkalias
    tmux
    obsidian
    nix-search-tv
    btop
    # home-manager
    cowsay
  ];

  # programs.nix-search-tv.enableTelevisionIntegration = true;

  system.activationScripts.applications.text =
    let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = "/Applications";
      };
    in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';

  # Change MacOS options
  system.defaults = {
    dock.autohide = false;
    dock.persistent-apps = [
      "${pkgs.alacritty}/Applications/Alacritty.app"
      "/Applications/Safari.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Calendar.app"
    ];
    # finder.FXPreferredView = "clmv";
    loginwindow.GuestEnabled = false;
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
  };
  system.primaryUser = userConfig.username;
  homebrew = {
    enable = true;
    # CLI apps
    brews = [
      "mas"
    ];
    # Gui apps
    casks = [
      "iina" # media player
      "hammerspoon" # interact with MacOS api with LUA
      # "the-unarchiver"
    ];
    # App Store
    # masApps = {
    #   "Yoink" = 457622435; # for id use `mas search <APPNAME>
    # };
    # uninstall all packages that not in lists
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  # nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.hostPlatform = "x86_64-darwin";
}
