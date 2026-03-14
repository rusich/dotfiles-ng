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
    musnix.url = "github:musnix/musnix";

    nix-yazi-plugins = {
      url = "github:lordkekz/nix-yazi-plugins?ref=yazi-v0.2.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      inherit (self) outputs;
      lib = inputs.nixpkgs.lib;

      # Define user configuration
      userConfig = {
        fullName = "Ruslan Sergin";
        username = "rusich";
        email = "ruslan.sergin@gmail.com";
        # avatar = ./assets/avatar; # put actual file
      };

      # Supported systems
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = lib.genAttrs systems;

      # Import overlays
      customOverlays = import ./overlays { inherit inputs; };

      # Common module configuration with overlays and allowUnfree
      commonModule = {
        nixpkgs.overlays = customOverlays ++ [ inputs.nixd.overlays.default ];
        nixpkgs.config.allowUnfree = true;
      };

      # Function to create pkgs with overlays for a specific system
      mkPkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = customOverlays;
          config.allowUnfree = true;
        };

      # Package sets for all systems
      pkgsFor = forAllSystems mkPkgs;

      # Helper function to create NixOS configurations
      mkNixosConfig =
        host:
        lib.nixosSystem {
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
        };

      # Helper function to create Darwin configurations
      mkDarwinConfig =
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
        };

      # Helper function to create Home Manager configurations
      mkHomeConfig =
        system:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.${system};
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

      # Get host directories
      nixosHosts = builtins.attrNames (builtins.readDir ./hosts/nixos);
      darwinHosts = builtins.attrNames (builtins.readDir ./hosts/darwin);

    in
    {
      nixosConfigurations = lib.genAttrs nixosHosts mkNixosConfig;
      darwinConfigurations = lib.genAttrs darwinHosts mkDarwinConfig;

      legacyPackages = forAllSystems (system: {
        homeConfigurations = {
          "rusich" = mkHomeConfig system;
        };
      });
    };
}
