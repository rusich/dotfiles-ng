{ pkgs, unstable, stateVersion, ... }:

{
  imports = [ ];

  # Host-specific configuration
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  console = { font = "ter-v24b"; };

  services.xserver.videoDrivers = [ "amdgpu" ];

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # Host-specific packages
  environment.systemPackages = with pkgs; [ mangohud ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}
