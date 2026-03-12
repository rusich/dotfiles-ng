{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    unstable.godot-mono
    unstable.godot-export-templates-bin
    unstable.gdtoolkit_4 # Godot4: Linter, Formatter, etc...
    dotnet-sdk_9
    unityhub
    gnome-terminal # needet to neovim integreation in unity editor
    # unstable.vscode
  ];
}
