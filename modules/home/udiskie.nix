{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        # replace with your favorite file manager
        file_manager = "${pkgs.nautilus}/bin/nautilus";
      };
    };
  };
}
