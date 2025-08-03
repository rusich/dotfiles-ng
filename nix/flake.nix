{
  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  
   };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
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
  in {
    nixosConfigurations = {
      matebook = lib.nixosSystem {
        inherit system;
	modules = [ 
	  ./system/configuration.nix 
	  # device-specific
	  # ./system/hosts/matebook/settings.nix
	  ./system/hosts/matebook/hardware-configuration.nix
	];
	specialArgs = {
	  inherit userSettings;
	  inherit unstable;
	};
      };
    };
    
    homeConfigurations = {
       ${userSettings.username} = home-manager.lib.homeManagerConfiguration {
         inherit pkgs;
	 modules = [ ./user/home.nix ];
	 extraSpecialArgs = {
	   inherit userSettings;
	   inherit unstable;
	 };
      };
    };
  };
}
