{ config, pkgs, lib, userSettings, ... }:
let
  myAliases = {
    # Standard
    "home-manager" = "home-manager --flake ~/.dotfiles/";
    # "ns" = "sudo nixos-rebuild switch --flake ~/.dotfiles/";
    # "hs" = "home-manager switch --flake ~/.dotfiles/";
    "os" = "nh os switch";
    "hs" = "nh home switch";
    "mc" = "/usr/bin/mc --nosubshell";
    "s" = "os && hs";

    # #fzf use preview
    # "fzf" =
    #   "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
    # ls and tree replacement with eza
    "ls" = "eza --icons --group-directories-first";
    "tree" = "eza --tree --icons --group-directories-first";

    # Nix packages online
    "lumen" = "nix run github:jnsahaj/lumen -- ";

    # OLD and almost unneeded

    # enable color support of ls and also add handy aliases
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    # alias grep='grep --color=auto'
    # alias fgrep='fgrep --color=auto'
    # alias egrep='egrep --color=auto'
    # some more ls aliases
    # alias ll='ls -alF'
    # alias la='ls -A'
    # alias l='ls -CF'

    # Add an "alert" alias for long running commands.  Use like so:
    #   sleep 10; alert
    # alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

    #alias bat="PAGER='less' /usr/bin/bat --theme Dracula"
  };
in {

  # Delta

  # try to separate file delta.nix (first try stylix!)
  # options.programs.git.include = lib.mkOption {
  #   type = lib.types.str; # Type of the custom option
  #   default = ""; # Default value (empty string)
  #   description =
  #     "Custom Git configuration setting."; # Description of the option
  # };

  programs.git = {
    # include.path = "./dotfiles/delta/themes.gitconfig";
    delta = {
      enable = true;
      options = {
        custom-theme = {
          dark = "true";
          syntax-theme = "TwoDark"; # from `bat` themes
          line-numbers = "true";
          side-by-side = "true";
          file-style = "brightwhite";
          file-decoration-style = "none";
          file-added-label = "[+]";
          file-copied-label = "[==]";
          file-modified-label = "[*]";
          file-removed-label = "[-]";
          file-renamed-label = "[->]";
          hunk-header-decoration-style = "#3e3e43 box ul";
          plus-style = "brightgreen black";
          plus-emph-style = "black green";
          minus-style = "brightred black";
          minus-emph-style = "black red";
          line-numbers-minus-style = "brightred";
          line-numbers-plus-style = "brightgreen";
          line-numbers-left-style = "#3e3e43";
          line-numbers-right-style = "#3e3e43";
          line-numbers-zero-style = "#57575f";
          zero-style = "syntax";
          whitespace-error-style = "black bold";
          blame-code-style = "syntax";
          blame-palette = "#161617 #1b1b1d #2a2a2d #3e3e43";
          merge-conflict-begin-symbol = "~";
          merge-conflict-end-symbol = "~";
          merge-conflict-ours-diff-header-style = "yellow bold";
          merge-conflict-ours-diff-header-decoration-style = "#3e3e43 box";
          merge-conflict-theirs-diff-header-style = "yellow bold";
          merge-conflict-theirs-diff-header-decoration-style = "#3e3e43 box";
        };
        features = "custom-theme";
        navigate = true;
        side-by-side = false;
        line-numbers = true;
        hyperlinks = true;
        hyperlinks-file-link-format = "file-line-column://{path}:{line}";
      };
    };
  };

  # Bat
  programs.bat = {
    enable = true;
    config = { theme = "Dracula"; };
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  # Starship
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableInteractive = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
      scan_timeout = 10;
    };
  };

  # Bash 
  programs.bash = {
    enable = true;
    shellAliases = myAliases;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # Fish 
  programs.fish = {
    enable = true;
    shellAliases = myAliases;
    interactiveShellInit = ''
        set fish_greeting # Disable greeting
        set -U FZF_LEGACY_KEYBINDINGS 0
        complete -c cht.sh -xa '(curl -s cheat.sh/:list)'

      if not set -q TMUX
          colorscript random
      end

    '';

    # # fzf-fish: diff highlighter
    # set fzf_diff_highlighter delta --paging=never --width=20
    # set fzf_fd_opts --hidden 
    # function rg
    # /usr/bin/env rg --json -C 2 $argv[1] | delta
    # end
    plugins = [
      # custom plugins here. see wiki
    ];
  };

  # Fish dependencies
  home.packages = with pkgs; [
    dwt1-shell-color-scripts
    fishPlugins.done # system notify when task is done
    fishPlugins.fzf-fish # https://github.com/PatrickF1/fzf.fish
    fishPlugins.grc # colorase common cli utilities output. Very cool!
    # fishPlugins.colored-man-pages # doesnt work
    fzf
    grc
    # fishPlugins.forgit # https://github.com/wfxr/forgit
    # fishPlugins.hydro # prompt instead of starship. https://github.com/jorgebucaran/hydro
  ];

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = myAliases;
    history.size = 10000;
  };

}
