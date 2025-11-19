{
  description = "NixOS, nix-darwin and home-manager config in one place!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # # Home Manager Stable
    # home-manager = {
    #   url = "github:nix-community/home-manager/release-25.05";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Home Manager Unstable
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # stylix = {
    #   url = "github:nix-community/stylix/release-25.05";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankMaterialShell
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.dgop.follows = "dgop";
    };

    # Noctalia shell
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.quickshell.follows = "quickshell"; # Use same quickshell version
    };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      stylix,
      nixvim,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Define user configuration
      users = {
        rusich = {
          fullName = "Ruslan Sergin";
          username = "rusich";
          email = "ruslan.sergin@gmail.com";
          # avatar = ./assets/avatar; # put actual file
        };
      };

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system an argument
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {

      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = builtins.listToAttrs (
        map (host: {
          name = host;
          value = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs outputs;
              userConfig = users.rusich;
              nixosModules = "${self}/modules/nixos";
              hostname = host;
            };
            modules = [
              ./hosts/nixos/${host}/configuration.nix
              ./modules/nixos/common
              stylix.nixosModules.stylix
              # ./common/theme.nix
            ];
          };
        }) (builtins.attrNames (builtins.readDir ./hosts/nixos))
      );

      # Darwin configuration
      darwinConfigurations = builtins.listToAttrs (
        map (host: {
          name = host;
          value = nix-darwin.lib.darwinSystem {
            specialArgs = {
              inherit inputs outputs;
              userConfig = users.rusich;
              darwinModules = "${self}/modules/darwin";
              hostname = host;
            };
            modules = [ ./hosts/darwin/${host}/configuration.nix ];
          };
        }) (builtins.attrNames (builtins.readDir ./hosts/darwin))
      );

      # Home-manager configuration
      legacyPackages = forAllSystems (system: {
        homeConfigurations."rusich" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            stylix.homeModules.stylix
            nixvim.homeModules.nixvim
            "${self}/modules/home"
          ];

          extraSpecialArgs = {
            inherit inputs outputs system;
            userConfig = users.rusich;
            homeModules = "${self}/modules/home";
          };
        };
      });

      # homeConfigurations = {
      #   ${userSettings.username} = home-manager.lib.homeManagerConfiguration {
      #     inherit pkgs;
      #     modules = [
      #       stylix.homeModules.stylix
      #       ./common/theme.nix
      #       ./home-manager
      #     ];
      #     extraSpecialArgs = {
      #       inherit
      #         userSettings
      #         unstable
      #         inputs
      #         system
      #         ;
      #     };
      #   };
      # };
    };
}
