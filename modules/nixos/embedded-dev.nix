{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.nixosModules.embedded-dev;
in
{
  options = {
    my.nixosModules.embedded-dev.enable = lib.mkEnableOption "Enable Embedded development options";
  };
  config = lib.mkIf cfg.enable {

    # FIXME: Discard manual `cargo install or rustup add`
    # Add embedded discovery guide requirements there: cargo-binutils, etc
    environment.systemPackages = with pkgs; [ gcc-arm-embedded ];

    services.udev = {
      enable = true;
      extraRules = ''
        # STM32F3DISCOVERY - ST-LINK/V2.1 RW access
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE:="0666"
      '';
    };
  };
}
