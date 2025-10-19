{
  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-colors.url = "github:misterio77/nix-colors";
    stylix.url = "github:nix-community/stylix/release-25.05";

    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

  };

  outputs =
    {
      self,
      stylix,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      unstable = nixpkgs-unstable.legacyPackages.${system};

      # My vars
      userSettings = rec {
        # rec - for reqursive
        username = "rusich";
        name = "Ruslan Sergin";
      };

      hosts = [
        {
          hostname = "matebook";
          stateVersion = "25.05";
        }
        {
          hostname = "nixos-vm";
          stateVersion = "25.05";
        }
        {
          hostname = "darkstar";
          stateVersion = "25.05";
        }
      ];

      makeSystem =
        { hostname, stateVersion }:
        nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit
              inputs
              hostname
              stateVersion
              userSettings
              unstable
              ;
          };
          modules = [
            stylix.nixosModules.stylix
            # ./common/theme.nix
            ./nixos/configuration.nix
            ./nixos/hosts/${hostname}/configuration.nix
            ./nixos/hosts/${hostname}/hardware-configuration.nix
          ];
        };

    in
    {
      nixosConfigurations = nixpkgs.lib.foldl' (
        configs: host:
        configs
        // {
          "${host.hostname}" = makeSystem { inherit (host) hostname stateVersion; };
        }
      ) { } hosts;

      homeConfigurations = {
        ${userSettings.username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            stylix.homeModules.stylix
            ./common/theme.nix
            ./home-manager
          ];
          extraSpecialArgs = {
            inherit
              userSettings
              unstable
              inputs
              system
              ;
          };
        };
      };
    };
}
