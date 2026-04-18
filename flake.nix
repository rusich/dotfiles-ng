{
  description = "NixOS, nix-darwin and home-manager config in one place!";

  inputs = rec {
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs = nixpkgs-stable;

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixd.url = "github:nix-community/nixd";

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix.url = "github:musnix/musnix";

    # nix-yazi-plugins = {
    #   url = "github:lordkekz/nix-yazi-plugins?ref=yazi-v0.2.5";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;

      # Define user configuration
      userConfig = {
        fullName = "Ruslan Sergin";
        username = "rusich";
        email = "ruslan.sergin@gmail.com";
      };

      # Supported systems
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Import overlays
      myOverlays = import ./overlays { inherit inputs; };

      # Common module for NixOS, nix-darwin and home-manager
      commonModule = {
        nixpkgs.overlays = myOverlays;
        nixpkgs.config.allowUnfree = true;
      };

      # Get host directories
      nixosHosts = builtins.attrNames (builtins.readDir ./hosts/nixos);
      darwinHosts = builtins.attrNames (builtins.readDir ./hosts/darwin);

    in
    rec {
      nixosConfigurations =
        nixpkgs.lib.genAttrs nixosHosts (
          host:
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs outputs;
              userConfig = userConfig;
              nixosModules = "${self}/modules/nixos";
              hostname = host;
            };
            modules = [
              commonModule
              ./modules/nixos/common
              ./hosts/nixos/${host}/configuration.nix
              inputs.stylix.nixosModules.stylix
            ];
          }
        )
        // {
          default = nixosConfigurations.darkstar; # nixd stub
        };

      legacyPackages = forAllSystems (system: {
        homeConfigurations = {
          ${userConfig.username} = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              inherit system;
              overlays = myOverlays;
            };
            modules = [
              commonModule
              inputs.stylix.homeModules.stylix
              "${self}/modules/home/default.nix"
            ];
            extraSpecialArgs = {
              inherit inputs outputs self;
              userConfig = userConfig;
            };
          };
          default = legacyPackages.${system}.homeConfigurations.${userConfig.username}; # nixd stub
        };
      });

      darwinConfigurations =
        nixpkgs.lib.genAttrs darwinHosts (
          host:
          inputs.nix-darwin.lib.darwinSystem {
            specialArgs = {
              inherit inputs outputs;
              userConfig = userConfig;
              darwinModules = "${self}/modules/darwin";
              hostname = host;
            };
            modules = [
              commonModule
              ./hosts/darwin/${host}/configuration.nix
            ];
          }
        )
        // {
          default = darwinConfigurations.macos-sonoma-vm; # nixd stub
        };
    };
}
