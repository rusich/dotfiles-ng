# Common settings for headless servers.
# Most server needs (openssh, fish, timezone, locales, nix settings, CLI
# packages) already come from modules/nixos/common.nix and
# modules/common/nix.nix; this profile only adds what is server-specific.
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.nixos.profiles.server;
in
{
  options = {
    nixos.profiles.server.enable = lib.mkEnableOption "unified headless-server profile (daily gc, resolved, key-only ssh)";
  };

  config = lib.mkIf cfg.enable {
    # Clean up more aggressively than desktops.
    nix.gc.dates = "daily";
    nix.optimise = {
      automatic = true;
      dates = [ "daily" ];
    };

    # Faster name resolution with per-link DNS caching.
    services.resolved.enable = true;

    # Keep the nixpkgs source (~485 MiB) out of the server closure:
    # nixpkgs.flake pins it into /etc/nix/registry.json and nix.nixPath by
    # default (see modules/common/nix.nix); servers don't need `<nixpkgs>`.
    nixpkgs.flake.setFlakeRegistry = lib.mkForce false;
    nixpkgs.flake.setNixPath = lib.mkForce false;
    nix.nixPath = lib.mkForce [ ];

    # Root is reachable with SSH keys only (bootstrap via nixos-anywhere);
    # console fallback is a password on the primary user (see users.nix).
    services.openssh.settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };

    # Only the bits missing from config.packages.common / modules/nixos/common.
    environment.systemPackages = with pkgs; [
      speedtest-cli
      net-tools # ifconfig, route (netstat already provided by unixtools.netstat)
    ];

    # Server-only disk savings: no man pages / nixos-help, and no
    # redistributable firmware (~790 MiB; not-detected.nix sets mkDefault
    # true, so force it off here). A bare-metal server must override with
    # hardware.enableRedistributableFirmware = lib.mkForce true.
    documentation.enable = false;
    hardware.enableRedistributableFirmware = lib.mkForce false;
  };
}
