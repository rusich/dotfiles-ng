{ ... }:
{
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
    fileWidgetOptions = [
      "--preview 'bat {} --style numbers,changes --color always | head -500'"
    ];
  };
}
