{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableInteractive = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
      scan_timeout = 10;
    };
  };
}