{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lsof
    curl
    procps # for pgrep dependency
  ];

  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
    # agents = {
    # };
  };
}
