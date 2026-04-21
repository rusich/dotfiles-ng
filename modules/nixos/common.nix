{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  vimAliases = {
    "v" = "nvim";
    "vim" = "nvim";
    "vi" = "nvim";
  };
in
{
  # imports =
  #   with builtins;
  #   map (fn: ./${fn}) (
  #     filter (fn: fn != "default.nix" && fn != "disabled") (attrNames (readDir "${nixosModules}/common"))
  #   );

  # NEOVIM
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.unstable.neovim-unwrapped;
  };

  programs.bash.shellAliases = vimAliases;
  programs.fish.shellAliases = vimAliases;
  programs.zsh.shellAliases = vimAliases;

  # NIX
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings = {
    http2 = true; # NOTE: turn off with DPI problems
  };

  # cleanup system automatically
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = "daily";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Nix store optimisation
  nix.settings.auto-optimise-store = true;
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };

  # Automatic upgrading
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
    # flake = "/path/to/flake";
    dates = "weekly";

  };

  # Fix hardware clock on dualboot
  time.hardwareClockInLocalTime = true;

  # Userful for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # PACKAGES

  environment.systemPackages = with pkgs; [
    nix-inspect # TODO: move to nix module
    file
    usbutils
    pciutils
    dig
    pkg-config
    openssl
    curl
    wget
    htop
    btop
    git
    ripgrep
    fzf
    unzip
    elinks
    killall
    traceroute
    lm_sensors
    inetutils
    nix-index
    mtr
    # is needed?
    nix-output-monitor # beautify nix output
    nvd
    nh # nix helper
    nix-du
    unixtools.netstat
    progress
    cifs-utils
    sshpass
  ];

}
