{
  userSettings,
  inputs,
  outputs,
  homeModules,
  userConfig,
  pkgs,
  ...
}:
{

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = rec {
    stateVersion = "25.05";
    username = userConfig.username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    # homeDirectory = "/Users/rusich";
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];

    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home.packages = with pkgs; [
    unstable.fastfetch
    neofetch
  ];

  # Enable alacritty
  programs.alacritty.enable = true;

  # # SwayOSD
  # services.swayosd.enable = true;

  # Remmina
  services.remmina.enable = true;

  # for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];


  # automatically import all home-manager modules

imports =
    with builtins;
    map
      (fn: ./${fn})
      (filter (fn: fn != "default.nix") (attrNames (readDir "${homeModules}" )));


}
