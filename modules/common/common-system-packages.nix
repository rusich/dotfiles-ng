{
  pkgs,
  lib,
  ...
}:

let
  nixosAndDarwinPackages = with pkgs; [
    neovim
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
    unrar
    p7zip
    elinks
    killall
    inetutils
    iperf3
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
    sshpass
    home-manager
    duf
    ncdu
    # To explore:
    # glances
    # termshark
    # ipcalc
    # lsof
    # procs
    # lazydocker
    # unp
    # asciinema + agg
  ];
in

{
  # Определяем опцию, которая будет содержать список пакетов
  options = {
    my.nixosAndDarwinPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = nixosAndDarwinPackages;
      readOnly = true;
      description = "Common packages list for NixOS and Darwin.\n(for use in environment.systemPackages)";
    };
  };
}
