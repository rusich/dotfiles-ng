{
  imports = [
    ./common.nix
    ../../presets/desktop.nix
  ];

  # Web-UI hub (traefik → phone) runs only on darkstar.
  features.opencode.server.enable = true;
}
