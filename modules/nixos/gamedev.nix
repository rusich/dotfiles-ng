{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    godot
    godot-export-templates-bin
    gdtoolkit_4 # Godot4: Linter, Formatter, etc...
  ];

  networking.firewall.allowedTCPPorts = [ 6006 ]; # allow godot debugger port

}
