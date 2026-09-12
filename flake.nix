{
  description = "NixOS, nix-darwin and home-manager config in one place!";

  # NOTE: release version is duplicated below because flake inputs require
  # literal URL strings (expressions are not allowed). Keep these three in sync:
  #   - nixpkgs-stable       nixos-<release>
  #   - nix-darwin           nix-darwin-<release>
  #   - home-manager         release-<release>
  inputs = rec {
    nixpkgs-stable.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs = nixpkgs-stable;

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # home-manager: manages dotfiles and user packages. Pinned to the release
    # branch matching the nixpkgs-stable channel; its nixpkgs input follows the
    # same `nixpkgs` as everything else to avoid dependency duplication.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix.url = "github:musnix/musnix";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Use noctalia theme in steam. Overlay must be set in ./overlays/default.nix
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;

      # Define user configuration
      primaryUser = import ./home/users/rusich/user.nix;

      # Import overlays
      overlays = import ./overlays { inherit inputs; };

      # Common module for NixOS, nix-darwin and home-manager
      overlayModule = {
        nixpkgs.overlays = overlays;
        # nixpkgs.config.allowUnfree = true;
      };

      # Get host directories
      nixosHosts = builtins.attrNames (builtins.readDir ./hosts/nixos);
      darwinHosts = builtins.attrNames (builtins.readDir ./hosts/darwin);

      # Module arguments shared by all systems
      args = host: {
        inherit inputs primaryUser;
        hostname = host;
      };

      mkNixos =
        host:
        lib.nixosSystem {
          specialArgs = args host;
          modules = [
            overlayModule
            ./modules/common
            ./modules/nixos
            ./hosts/nixos/${host}/configuration.nix
            # inputs.stylix.nixosModules.stylix
          ];
        };

      mkDarwin =
        host:
        inputs.nix-darwin.lib.darwinSystem {
          specialArgs = args host;
          modules = [
            overlayModule
            ./modules/common
            ./modules/darwin
            ./hosts/darwin/${host}/configuration.nix
          ];
        };

      # home-manager per host: общий набор модулей (./modules/home) для всех
      # систем; различаются только pkgs (system) и hostname (per-host).
      # Ключи вида `rusich@<host>` — штатная конвенция home-manager: при
      # `home-manager switch --flake .` CLI сам находит `user@<hostname>`.
      mkHome =
        system: host:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = overlays;
          };
          modules = [
            overlayModule
            ./modules/common
            ./modules/home
            # inputs.stylix.homeModules.stylix
          ];
          extraSpecialArgs = args host;
        };

      namedHomes =
        system: hosts:
        lib.mapAttrs' (host: cfg: lib.nameValuePair "${primaryUser.username}@${host}" cfg) (
          lib.genAttrs hosts (mkHome system)
        );

      # Ключ `default` — только для nixd и явного `.#default`; авто-детект CLI
      # (`home-manager switch --flake .`) использует `user@<hostname>`, поэтому
      # неизвестный хост честно падает.
      nixosAll = lib.genAttrs nixosHosts mkNixos;
      darwinAll = lib.genAttrs darwinHosts mkDarwin;
      homeAll = (namedHomes "x86_64-linux" nixosHosts) // (namedHomes "aarch64-darwin" darwinHosts);
    in
    {
      formatter = {
        x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
        aarch64-darwin = inputs.nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
      };
      nixosConfigurations = nixosAll // {
        default = nixosAll.darkstar;
      };
      darwinConfigurations = darwinAll // {
        default = darwinAll.macos-sonoma-vm;
      };
      homeConfigurations = homeAll // {
        default = homeAll."${primaryUser.username}@darkstar";
      };
    };
}
