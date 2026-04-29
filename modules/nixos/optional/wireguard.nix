
{pkgs,...}:
{
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # brightnessctl
    # powertop
    wireguard-tools
    wireguard-ui
  ];
}
