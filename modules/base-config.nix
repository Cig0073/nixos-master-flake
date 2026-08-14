{ pkgs, inputs, ... }:
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

  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  programs.nix-index-database.comma.enable = true;  

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

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

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

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
    fastfetch
    comma
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
