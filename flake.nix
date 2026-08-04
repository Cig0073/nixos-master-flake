{
  description = "NixCore - All configs for my machines(cig0073)";

  inputs = {
  	nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Jovian tracking development
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixkit = {
      url = "github:frostplexx/nixkit";
      inputs.nixpkgs.follows = "nixpkgs";	
    };
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ytm-player = {
      url = "github:peternaame-boop/ytm-player";	
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, jovian-nixos, chaotic, arion, millennium, home-manager, ytm-player, nixos-hardware, ... }@inputs:
    let
      inherit (chaotic.vendored) jovian;
    in
    {
  	nixosConfigurations = {

  	  nixos-fremont = nixpkgs.lib.nixosSystem {
    		system = "x86_64-linux";
    		specialArgs = { inherit inputs; };
   	   	modules = [ 
   	  	  jovian-nixos.nixosModules.default
   	  	  chaotic.nixosModules.default
   	  	  inputs.nixkit.nixosModules.default
   	      ./nixos-fremont
   	      ./modules/gaming.nix
   	      ./modules/gaming-jovian.nix
   	      ./modules/sunshine.nix
 	      ];
  	  };

	    nixos-vault = nixpkgs.lib.nixosSystem {
	      system = "x86_64-linux";
	      specialArgs = { inherit inputs; }; 
        modules = [ 
          ./nixos-vault
        ];
      };

      nixbook-air = nixpkgs.lib.nixosSystem {
        modules = [ 
        ./modules/base-config.nix
        ./modules/limine.nix
        ./nixbook-air
        ./modules/gaming.nix
        ./modules/niri/niri.nix
        home-manager.nixosModules.default
        chaotic.nixosModules.default
        {
        	nixpkgs.overlays = [ ytm-player.overlays.default ];
        	home-manager = {
        	  useGlobalPkgs = true;
        	  useUserPackages = true;
        	  users.cig0073 = ./modules/home.nix; # replace <USERNAME> with your actual username
        	};
        }
        ];
      };
      
      nixos-ally = nixpkgs.lib.nixosSystem {
        modules = [ 
        ./nixos-ally
        nixos-hardware.nixosModules.asus-ally-rc71l
        ./modules/limine.nix
        home-manager.nixosModules.default
        chaotic.nixosModules.default
        {
        	nixpkgs.overlays = [ ytm-player.overlays.default ];
        	home-manager = {
        	  useGlobalPkgs = true;
        	  useUserPackages = true;
        	  users.cig0073 = ./modules/home.nix; # replace <USERNAME> with your actual username
        	};
        }
        ];
      };
    };	  
  };
}
