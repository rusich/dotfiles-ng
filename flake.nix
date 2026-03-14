{
  description = "NixOS, nix-darwin and home-manager config in one place!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixd.url = "github:nix-community/nixd";

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankMaterialShell
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # using in ./modules/nixos/DAW.nix
    musnix = {
      url = "github:musnix/musnix";
    };

    nix-yazi-plugins = {
      url = "github:lordkekz/nix-yazi-plugins?ref=yazi-v0.2.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
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

      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

      # Импортируем overlays
      custom_overlays = import ./overlays { inherit inputs; };

      # Функция для создания pkgs с overlays для конкретной системы
      mkPkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          # stdenv.hostPlatform.system = system;
          overlays = custom_overlays;
          config.allowUnfree = true;
        };

      # Создаем пакетные наборы для всех систем
      pkgsFor = forAllSystems mkPkgs;
    in
    {
      # legacyPackages = pkgsFor;

      nixosConfigurations = builtins.listToAttrs (
        map (host: {
          name = host;
          value = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs outputs;
              userConfig = users.rusich;
              nixosModules = "${self}/modules/nixos";
              hostname = host;
            };
            modules = [
              # Oerlays loading to nixpkgs
              {
                nixpkgs.overlays = custom_overlays ++ [
                  inputs.nixd.overlays.default
                ];
                nixpkgs.config.allowUnfree = true;
              }
              ./modules/nixos/common
              ./hosts/nixos/${host}/configuration.nix
              inputs.stylix.nixosModules.stylix
              # ./common/theme.nix
            ];
          };
        }) (builtins.attrNames (builtins.readDir ./hosts/nixos))
      );

      # Darwin configuration
      darwinConfigurations = builtins.listToAttrs (
        map (host: {
          name = host;
          value = inputs.nix-darwin.lib.darwinSystem {
            specialArgs = {
              inherit inputs outputs;
              userConfig = users.rusich;
              darwinModules = "${self}/modules/darwin";
              hostname = host;
            };
            modules = [
              # Oerlays loading to nixpkgs
              {
                nixpkgs.overlays = custom_overlays ++ [
                  inputs.nixd.overlays.default
                ];
                nixpkgs.config.allowUnfree = true;
              }
              ./hosts/darwin/${host}/configuration.nix
            ];
          };
        }) (builtins.attrNames (builtins.readDir ./hosts/darwin))
      );

      # Home-manager configuration
      legacyPackages = forAllSystems (system: {
        homeConfigurations = {
          "rusich" = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsFor.${system}; # Используем pkgs с overlays
            modules = [
              {
                nixpkgs.overlays = custom_overlays ++ [
                  inputs.nixd.overlays.default
                ];
                nixpkgs.config.allowUnfree = true;
              }
              inputs.stylix.homeModules.stylix
              "${self}/modules/home/default.nix"
            ];

            extraSpecialArgs = {
              inherit inputs outputs self;
              userConfig = users.rusich;
              # homeModules = "${self}/modules/home";
            };
          };
        };
      });
    };
}
