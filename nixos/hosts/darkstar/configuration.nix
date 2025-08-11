{ pkgs, unstable, stateVersion, ... }:

{
  imports = [ ];

  # Host-specific configuration
  console = { font = "ter-v24b"; };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [ mangohud ];

  services.xserver.videoDrivers = [ "amdgpu" ];
  # Host-specific packages
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  services.desktopManager.plasma6.enable = true;

  users.users.zaychik = {
    isNormalUser = true;
    description = "Sakhaya Sergina";
    extraGroups = [ "networkmanager" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}
