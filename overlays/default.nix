{ inputs, ... }:
let

  # Кастомные пакет: можно как переопределять через overlay существующие в nixpkgs,
  # так и добавлять полностью свои в директории ../pkgs.
  custom-packages =
    final: prev:
    let
      myPackages = prev.lib.packagesFromDirectoryRecursive {
        callPackage = prev.lib.callPackageWith final;
        directory = ../pkgs;
      };
    in
    {
      custom = myPackages // {
        # Также можно добавить переопределенные версии стандартных пакетов
        tonelib-gfx = prev.tonelib-gfx.overrideAttrs (oldAttrs: {
          version = "4.9.0";
          src = prev.fetchurl {
            url = "https://tonelib.vip/download/25-11-10/ToneLib-GFX-amd64.deb";
            hash = "sha256-WL9kV50R5AGG57I5IkNz7EKd4NPlf0iO+QiE8k+E26Q=";
          };
          buildInputs = oldAttrs.buildInputs ++ [
            prev.fontconfig
          ];
        });
      };
    };

  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
      # overlays = [
      # ];
    };
  };

  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = prev.stdenv.hostPlatform.system;
      config.allowUnfree = true;
      # overlays = [
      # ];
    };
  };
in
[
  custom-packages # ← ДОЛЖЕН БЫТЬ ПЕРВЫМ, чтобы другие overlays могли его использовать
  stable-packages
  unstable-packages
]
