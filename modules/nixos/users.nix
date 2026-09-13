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
  };

  # Allow SSH as root (used by nixos-anywhere / nixos-rebuild --target-host).
  users.users.root.openssh.authorizedKeys.keys = primaryUser.sshKeys or [ ];
}
