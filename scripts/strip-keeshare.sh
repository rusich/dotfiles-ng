#!/usr/bin/env sh
# Git clean filter for home/features/gui/keepassxc/keepassxc.ini.
#
# KeePassXC writes a [KeeShare] section into its config, including an RSA
# private key (KeeShare/.../Own). The config is symlinked out-of-store, so
# runtime writes land directly in the repo. KeeShare is unused here, so this
# filter strips the whole section (and the blank line before it) before the
# file is committed, keeping the private key out of the (public) repository.
#
# Registered declaratively in home/common/git.nix.
awk '
  /^\[KeeShare\]/ { skip = 1; blanks = 0; next }
  /^\[/           { skip = 0 }
  skip            { next }
  /^$/            { blanks++; next }
  {
    while (blanks > 0) { print ""; blanks-- }
    print
  }
  END {
    while (blanks > 0) { print ""; blanks-- }
  }
'
