{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.dev.rust;
in
{
  options.features.dev.rust.enable = lib.mkEnableOption "rust toolchain (rustup)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rustup
    ];

    home.sessionPath = [ "$HOME/.cargo/bin" ];
  };
}
