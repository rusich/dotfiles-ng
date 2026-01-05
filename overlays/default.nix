# This file defines oerlays/custom modifications tu upstream packages
{ inputs, ... }:
let
  # Adds my custom packages
  # additions =
  #   final: prev:
  #   (prev.lib.packagesFromDirectoryRecursive {
  #     callPackage = prev.lib.callPackageWith final;
  #     directory = ../pkgs;
  #   });

  # linuxModifications = final: prev: prev.lib.optionalAttrs final.stdenv.isLinux { };

  modifications = final: prev: {
    # example = prev.example.overrideAttrs (prevAttrs: let ... in {
    # });
  };

  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      # inherit (final) system;
      system = prev.stdenv.hostPlatform.system;
      config.allowUnfree = true;
      overlays = [
        # Latest Tonelib-GFX
        (unstable_final: unstable_prev: {
          tonelib-gfx = unstable_prev.tonelib-gfx.overrideAttrs (oldAttrs: {
            version = "4.9.0";
            src = unstable_prev.fetchurl {
              url = "https://tonelib.vip/download/25-11-10/ToneLib-GFX-amd64.deb";
              hash = "sha256-WL9kV50R5AGG57I5IkNz7EKd4NPlf0iO+QiE8k+E26Q=";
            };
            buildInputs = oldAttrs.buildInputs ++ [
              unstable_prev.fontconfig
            ];
          });
        })

        # Tonelib GrandMagus (based on tonelib-gfx derivation)
        # (unstable_final: unstable_prev: {
        #   tonelib-grand-magus = unstable_prev.tonelib-gfx.overrideAttrs (oldAttrs: {
        #     pname = "tonelib-grand-magus";
        #     version = "1.0.0";
        #     src = unstable_prev.fetchurl {
        #       url = "https://tonelib.vip/download/25-11-10/ToneLib-GrandMagus-amd64.deb";
        #       hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        #     };
        #     buildInputs = oldAttrs.buildInputs ++ [
        #       unstable_prev.fontconfig
        #     ];
        #   });
        # })
      ];
    };
  };
in
[
  # additions
  modifications
  # linuxModifications
  stable-packages
  unstable-packages
]
