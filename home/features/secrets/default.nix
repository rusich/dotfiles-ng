{
  config,
  lib,
  ...
}:
let
  cfg = config.user.secrets;
in
{
  options.user.secrets.enable = lib.mkEnableOption "sops-nix secrets (personal age key)";

  config = lib.mkIf cfg.enable {
    # Secrets are decrypted at activation by the user-level sops-nix.service,
    # which reads the personal age key (must have no password). Encrypted files
    # live in secrets/ and are consumed via config.sops.secrets."<name>".path.
    sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Encrypted secrets file for this user (age-encrypted to &admin).
    sops.defaultSopsFile = ../../../secrets/users/rusich.yaml;

    # Each key is extracted from the file above into
    # ~/.config/sops-nix/secrets/<name> at activation.
    sops.secrets = {
      "nextcloud/url" = { };
      "nextcloud/username" = { };
      "nextcloud/password" = { };
      "opencode/server-username" = { };
      "opencode/server-password" = { };
      "keepass/database-password" = { };
    };
  };
}
