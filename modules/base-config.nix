{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"         # Enables the modern 'nix' CLI commands (like nix shell, nix run)
    "flakes"              # Enables flakes for modular, lockfile-reproducible system setups
    "ca-derivations"      # Content-addressed derivations (optimizes the store based on content output hashes)
    "auto-allocate-uids"  # Allows Nix to dynamically pick UIDs for builds instead of hardcoded build groups
    "impure-derivations"  # Allows running derivations that pull outside system contexts safely
    "recursive-nix"       # Permits executing Nix builds nested within another running Nix derivation
  ];

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # 1. Set NetworkManager to use iwd as its Wi-Fi backend
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    wifi.powersave = false; # Prevents the Wi-Fi chip from dropping into low-power latency states
  };
  # 2. Configure iwd to disable background periodic scanning
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Scan = {
        DisablePeriodicScan = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };
  networking.firewall.enable = true;
	
  services.upower.enable = true;
  services.printing.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      fastfetch
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cig0073 = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "input" "uinput" ];
    shell = pkgs.fish;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
    priority = 5;
  };

  environment.systemPackages = with pkgs; [
    helix
    git
    wget 
    tldr
    wl-clipboard
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
      };
    };
   system = {
     activationScripts = {
       # Print a summary of nixos-rebuild changes
       diff = {
         supportsDryActivation = true;
         text = ''
           ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff \
             /run/current-system "$systemConfig"
         '';
      };
    };
  };
}
