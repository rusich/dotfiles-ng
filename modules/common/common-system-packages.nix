{
  pkgs,
  lib,
  ...
}:

let
  commonSystemPackages = with pkgs; [
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
    unzip
    elinks
    killall
    traceroute
    lm_sensors
    inetutils
    nix-index
    nix-inspect # TODO: move to nix module
    mtr
    # is needed?
    nix-output-monitor # beautify nix output
    nvd
    nh # nix helper
    nix-du
    unixtools.netstat
    progress
    cifs-utils
    sshpass
  ];
in

{
  # Определяем опцию, которая будет содержать список пакетов
  options = {
    commonSystemPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = commonSystemPackages;
      readOnly = true;
      description = "Common packages list for NixOS and Darwin.\n(for use in environment.systemPackages)";
    };
  };
}
