{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.dev.rust;
in
{
  options.user.dev.rust.enable = lib.mkEnableOption "rust toolchain (rustup)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rustup
    ];

    home.sessionPath = [ "$HOME/.cargo/bin" ];
  };
}
