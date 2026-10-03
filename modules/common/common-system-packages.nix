{
  pkgs,
  lib,
  ...
}:

let
  commonPackages = with pkgs; [
    file
    usbutils
    pciutils
    dig
    openssl
    curl
    wget
    # Secrets: sops to edit/decrypt (age-backed); age/ssh-to-age to manage
    # recipients (derive host age keys from SSH host keys).
    sops
    age
    ssh-to-age
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
    gping
    # is needed?
    nix-output-monitor # beautify nix output
    nvd
    nix-du
    unixtools.netstat
    progress
    sshpass
    home-manager
    duf
    ncdu
    pv
    just
    # To explore:
    # glances
    # termshark
    # ipcalc
    # lsof
    # procs
    # unp
    # asciinema + agg
  ];
in

{
  # Определяем опцию, которая будет содержать список пакетов
  options = {
    packages.common = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = commonPackages;
      readOnly = true;
      description = "Common packages list for NixOS.\n(for use in environment.systemPackages)";
    };
  };
}
