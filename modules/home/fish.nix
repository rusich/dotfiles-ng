{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
        set fish_greeting # Disable greeting
        set -U FZF_LEGACY_KEYBINDINGS 0
        complete -c cht.sh -xa '(curl -s cheat.sh/:list)'

      if not set -q TMUX
          colorscript random
      end
    '';

    plugins = [
      # custom plugins here. see wiki
    ];
  };

  home.packages = with pkgs; [
    dwt1-shell-color-scripts
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.grc
    grc
  ];
}
