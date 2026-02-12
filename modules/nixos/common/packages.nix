{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    file
    usbutils
    pciutils
    dig
    pkg-config
    openssl
    curl
    wget
    htop
    btop
    git
    ripgrep
    fzf
    unzip
    elinks
    killall
    traceroute
    lm_sensors
    inetutils
    nix-index
    mtr
    # is needed?
    nix-output-monitor # beautify nix output
    nvd
    nh # nix helper
    nix-du
    unixtools.netstat
    progress
  ];
}
