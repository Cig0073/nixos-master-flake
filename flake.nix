{
  description = "NixCore - All configs for my machines (cig0073)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Jovian NixOS (Steam Deck / SteamOS-like experience)
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Chaotic Nyx (AUR-inspired extra packages + kernel choices)
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community overlay / tooling
    nixkit = {
      url = "github:frostplexx/nixkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Extra packages / applications
    ytm-player = {
      url = "github:peternaame-boop/ytm-player";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware-specific modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, jovian-nixos, chaotic, arion, millennium,
              home-manager, ytm-player, nixos-hardware, nix-index-database,
              ... }@inputs:
    let
      # Shared specialArgs passed to every host
      sharedArgs = { inherit inputs; };

      # Shared Home Manager inline module (ytm-player overlay + HM defaults)
      # Used by every desktop/laptop host.
      hmSharedModule = {
        nixpkgs.overlays = [ ytm-player.overlays.default ];
        home-manager = {
          useGlobalPkgs    = true;
          useUserPackages  = true;
          users.cig0073    = ./modules/home.nix;
        };
      };

      # Common modules shared by every desktop-class host
      desktopModules = [
        ./modules/base-config.nix
        ./modules/limine/limine.nix
        ./modules/gaming.nix
        ./modules/gaming-liberated.nix
        home-manager.nixosModules.default
        chaotic.nixosModules.default
        inputs.nixkit.nixosModules.default
        hmSharedModule
      ];
    in
    {
      nixosConfigurations = {

        # ── nixos-fremont ──────────────────────────────────────────────────
        # SteamOS-style HTPC / Jovian host (living room PC)
        nixos-fremont = nixpkgs.lib.nixosSystem {
          system     = "x86_64-linux";
          specialArgs = sharedArgs;
          modules    = [
            jovian-nixos.nixosModules.default
            chaotic.nixosModules.default
            inputs.nixkit.nixosModules.default
            ./nixos-fremont
            ./modules/base-config.nix
            ./modules/gaming.nix
            ./modules/gaming-jovian.nix
            ./modules/sunshine.nix
            ./modules/steamos-system-modifications.nix
            ./modules/sshd-suspend-inhibit.nix
            ./modules/limine/limine.nix
          ];
        };

        # ── nixos-chell ────────────────────────────────────────────────────
        # Desktop gaming rig running Niri
        nixos-chell = nixpkgs.lib.nixosSystem {
          system     = "x86_64-linux";
          specialArgs = sharedArgs;
          modules    = desktopModules ++ [
            ./nixos-chell
            ./modules/sunshine.nix
            ./modules/niri/niri.nix
          ];
        };

        # ── nixos-viscous ──────────────────────────────────────────────────
        # Laptop with NVIDIA hybrid graphics
        nixos-viscous = nixpkgs.lib.nixosSystem {
          system     = "x86_64-linux";
          specialArgs = sharedArgs;
          modules    = desktopModules ++ [
            ./nixos-viscous
          ];
        };

        # ── nixos-vault ────────────────────────────────────────────────────
        # Main PC / homelab server — extends nixos-chell
        nixos-vault = nixpkgs.lib.nixosSystem {
          system     = "x86_64-linux";
          specialArgs = sharedArgs;
          modules    = desktopModules ++ [
            ./nixos-vault
            ./modules/sunshine.nix
            ./modules/niri/niri.nix
          ];
        };

        # ── nixbook-air ────────────────────────────────────────────────────
        # Intel laptop with Niri
        nixbook-air = nixpkgs.lib.nixosSystem {
          system     = "x86_64-linux";
          specialArgs = sharedArgs;
          modules    = desktopModules ++ [
            ./nixbook-air
            ./modules/niri/niri.nix
          ];
        };

        # ── nixos-ally ─────────────────────────────────────────────────────
        # ASUS ROG Ally handheld
        nixos-ally = nixpkgs.lib.nixosSystem {
          system     = "x86_64-linux";
          specialArgs = sharedArgs;
          modules    = [
            nixos-hardware.nixosModules.asus-ally-rc71l
            ./nixos-ally
            ./modules/base-config.nix
            ./modules/gaming.nix
            ./modules/limine/limine.nix
            home-manager.nixosModules.default
            chaotic.nixosModules.default
            hmSharedModule
          ];
        };
      };
    };
}
