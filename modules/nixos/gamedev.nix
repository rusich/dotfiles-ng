{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    godot_4-mono
    godot_4-export-templates-bin
    gdtoolkit_4 # Godot4: Linter, Formatter, etc...
  ];

}
