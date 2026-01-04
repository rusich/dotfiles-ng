{ inputs, ... }:
{
  # When applied, the stable unstable nixpkgs sety (declared in the flake inputs)
  # will be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      # system = final.system;
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
