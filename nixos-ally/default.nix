# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./rog-ally-quirks.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"         # Enables the modern 'nix' CLI commands (like nix shell, nix run)
    "flakes"              # Enables flakes for modular, lockfile-reproducible system setups
    "ca-derivations"      # Content-addressed derivations (optimizes the store based on content output hashes)
    "auto-allocate-uids"  # Allows Nix to dynamically pick UIDs for builds instead of hardcoded build groups
    "impure-derivations"  # Allows running derivations that pull outside system contexts safely
    "recursive-nix"       # Permits executing Nix builds nested within another running Nix derivation
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

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

   # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  programs.kdeconnect = {
    enable = true;
  };
  
  services.upower.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

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
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    extest.enable = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-cachyos ];
  };


  programs.niri.enable = true;
  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service



  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true;             # Systemd service for auto-start
      restartIfChanged = true;   # Auto-restart dms.service when dms-shell changes
    };
  
    # Core features
    enableSystemMonitoring = true;     # System monitoring widgets (dgop)
    enableVPN = true;                  # VPN management widget
    enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
    enableAudioWavelength = true;      # Audio visualizer (cava)
    enableCalendarEvents = true;       # Calendar integration (khal)
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";  # Or "hyprland" or "sway"
    configHome = "/home/cig0073";
  };

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "cig0073";
    };

  # Required for auto-login: identifies which session to launch.
  # Use the .desktop basename without the extension (e.g. "niri", "hyprland").
    defaultSession = "niri";
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    micro-full # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    wget 
    tldr
    wl-clipboard
  ];
  
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
    priority = 5;
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
      };
    };

   #
   # System
   #
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

  system.stateVersion = "26.05"; # Did you read the comment?

}

