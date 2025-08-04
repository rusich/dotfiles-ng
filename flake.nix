{
  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  
   };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let 
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    unstable = nixpkgs-unstable.legacyPackages.${system};

    # My vars
    userSettings = rec { # rec - for reqursive
      username = "rusich";
      name = "Ruslan Sergin";
    };

    hosts = [
      { hostname = "matebook"; stateVersion = "25.05"; }
      { hostname = "nixos-vm"; stateVersion = "25.05"; }
    ];

    makeSystem = { hostname, stateVersion, }: nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = {
        inherit inputs hostname stateVersion userSettings unstable;
      };
      modules = [
        ./nixos/configuration.nix
	./nixos/hosts/${hostname}/configuration.nix
	./nixos/hosts/${hostname}/hardware-configuration.nix
      ];
    };


  in {
    nixosConfigurations = nixpkgs.lib.foldl' (configs: host:
      configs // {
        "${host.hostname}" = makeSystem {
	  inherit (host) hostname stateVersion;
	};
      }) {} hosts;
	# Simple configuration example
	#    nixosConfigurations = {
	#      matebook = lib.nixosSystem {
	#        inherit system;
	# modules = [ 
	#   ./system/configuration.nix 
	#   ./system/hosts/matebook/hardware-configuration.nix
	# ];
	# specialArgs = {
	#   inherit userSettings;
	#   inherit unstable;
	# };
	#      };
	#    };
    
    homeConfigurations = {
       ${userSettings.username} = home-manager.lib.homeManagerConfiguration {
         inherit pkgs;
	 modules = [ ./home-manager/home.nix ];
	 extraSpecialArgs = {
	   inherit userSettings unstable inputs;
	 };
      };
    };
  };
}
