{ config, pkgs, userSettings, ... }: {

  home.sessionPath = [
    "$HOME/bin/"
    "$HOME/dev/flutter/bin"
    "$ANDROID_HOME/platform-tools"
    "$ANDROID_HOME/cmdline-tools/latest/bin"

    # ##### PATH #####
    # PATH="$HOME/.cabal/bin:$PATH"
    # PATH="$HOME/.ghcup/bin:$PATH"
    # PATH="$HOME/bin:$PATH"
    # PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
    # PATH="$HOME/.cargo/bin:$PATH"
    # PATH="$HOME/.luarocks/bin:$PATH"
    # PATH="$HOME/.r2env/versions/radare2@git/bin:$PATH"
    # PATH="$HOME/.local/bin:$PATH"
  ];

}
