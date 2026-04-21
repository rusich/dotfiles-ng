{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # godot
    godot-mono
    gdtoolkit_4 # Godot4: Linter, Formatter, etc...
    blender
    # unstable.godot-mono
    dotnet-sdk_10
    # unstable.godot-export-templates-bin
    # omnisharp-roslyn
    # dotnet-sdk_9
    # omnisharp-roslyn
    # unityhub
    # gnome-terminal # needet to neovim integreation in unity editor
    # unstable.vscode
  ];

  # NOTE: Enable this if dotnet-sdk is enabled
  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet/";
  };
}
