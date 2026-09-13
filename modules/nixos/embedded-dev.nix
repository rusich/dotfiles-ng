{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixos.profiles.embedded;
in
{
  options = {
    nixos.profiles.embedded.enable = lib.mkEnableOption "Enable Embedded development options";
  };
  config = lib.mkIf cfg.enable {

    # FIXME: Discard manual `cargo install or rustup add`
    # Add embedded discovery guide requirements there: cargo-binutils, etc
    environment.systemPackages = with pkgs; [
      gcc-arm-embedded
      # embedded rust addition
      gdb
      openocd
      minicom
      fastfetch
      neo
    ];

    services.udev = {
      enable = true;
      extraRules = ''
        # STM32F3DISCOVERY - ST-LINK/V2.1 RW access
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE:="0666"
      '';
    };
  };
}
