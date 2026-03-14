{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    unstable.godot-mono
    unstable.gdtoolkit_4 # Godot4: Linter, Formatter, etc...
    blender
    # unstable.godot-export-templates-bin
    # omnisharp-roslyn
    # dotnet-sdk_9
    dotnet-sdk_10
    # omnisharp-roslyn
    # unityhub
    # gnome-terminal # needet to neovim integreation in unity editor
    # unstable.vscode
  ];
  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet/";
  };
}
