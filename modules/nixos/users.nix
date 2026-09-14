{
  pkgs,
  primaryUser,
  ...
}:
{
  # Fish as the default shell for all users (built-in NixOS mechanism)
  users.defaultUserShell = pkgs.fish;

  # Primary user account, shared by all hosts.
  # wheel grants sudo; every other group is added by the modules that need it.
  users.users.${primaryUser.username} = {
    isNormalUser = true;
    description = primaryUser.fullName;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = primaryUser.sshKeys or [ ];
    # Console fallback (SSH stays key-only). The hash lives in
    # home/users/<user>/user.nix; a `null`/absent value leaves the account with
    # no password. Seam for sops-nix: replace this with
    # hashedPasswordFile = config.sops.secrets."<user>-password".path; and set
    # users.mutableUsers = false.
    initialHashedPassword = primaryUser.hashedPassword or null;
  };

  # Allow SSH as root (used by nixos-anywhere / nixos-rebuild --target-host).
  # It is deliberately key-only: no password, PermitRootLogin=prohibit-password.
  users.users.root.openssh.authorizedKeys.keys = primaryUser.sshKeys or [ ];
}
