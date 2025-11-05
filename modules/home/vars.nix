{
  home.sessionVariables = {
    NH_FLAKE = "$HOME/.dotfiles";
    PAGER = "less";
    MANROFFOPT = "-c";
    # MANPAGER = "sh -c 'col -bx | bat --theme Dracula -l man -p'";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    # PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    # # for virsh
    LIBVIRT_DEFAULT_URI = "qemu:///system";
    # # ssh-agent init
    # eval $(ssh-agent)
  };
}
