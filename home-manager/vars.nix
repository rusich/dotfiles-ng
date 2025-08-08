{ config, pkgs, userSettings, ... }: {

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/rusich/etc/profile.d/hm-session-vars.sh
  #

  home.sessionVariables = {

    EDITOR = "nvim";
    PAGER = "less";
    MANPAGER = "sh -c 'col -bx | bat --theme Dracula -l man -p'";
    OVERRIDE_TERMINAL_CMD = "kitty sh -c ";
    MANROFFOPT = "-c";
    # Android + Flutter
    ANDROID_HOME = "$HOME/dev/android-sdk";
    # JAVA_HOME="/usr/lib/jvm/java-17-openjdk
    # umask 0077
    # export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
    # # for virsh
    # export LIBVIRT_DEFAULT_URI="qemu:///system"
    # # ssh-agent init
    # eval $(ssh-agent)
    #
    # # Luarocks fix for busted
    # eval $(nluarocks path --no-bin)
    #
  };
}
