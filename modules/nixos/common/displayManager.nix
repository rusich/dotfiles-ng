{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    sddm-chili-theme
    sddm-astronaut
    sddm-sugar-dark
  ];
  # SDDM
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # GDM
  # services.xserver.displayManager.gdm.enable = true;
}
