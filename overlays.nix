{ inputs, pkgs, ... }:
{

  tonelib-gfx = pkgs.tonelib-gfx.overrideAttrs (old: {
    version = "4.9.0"; # New version
    src = pkgs.fetchurl {
      url = "https://tonelib.vip/download/25-11-10/ToneLib-GFX-amd64.deb"; # Source URL
      sha256 = "sha256-<new-hash>"; # Replace <new-hash> with the correct SHA256 hash
    };
  });

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      # system = final.system;
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
