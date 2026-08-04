# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{

  inputs = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
    # Use latest kernel.
  kernelPackages = pkgs.linuxPackages_latest;
  
  plymouth = {
    enable = true;
    theme = "motion";
    themePackages = with pkgs; [
      # By default we would install all themes
      (adi1090x-plymouth-themes.override {
        selected_themes = [ "motion" ];
      })
    ];
  };
  boot = {
    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };

  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

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

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      fastfetch
    '';
  };
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
  	enable = true;
  	enableHidpi = true;
  	wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sessionPackages = [
  	pkgs.kdePackages.plasma-bigscreen
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."cig0073" = {
    isNormalUser = true;
    description = "Cig0073";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "uinput" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      kdePackages.kate
      jellyfin-tui
    #  thunderbird
    ];
    hashedPassword = "$6$nwdrlyxXsr/tOvwm$7ghcLX0QDdU5Pql.ogFnHGQI2ZR/Bfk3i4RQJVQmICMJikFof09mMiOlpsE0Lh5gIOdh5Biumtdue.kULGcxp1"; # <<<--- Generate your own initial hashed password
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    git
  	wget
  	micro-full
  	kdePackages.plasma-bigscreen
    kdePackages.plasma-keyboard
    tldr
  	kdePackages.partitionmanager
  	fastfetch
  	helix
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
   networking.firewall.enable = true;

   #
   # Nix
   #
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
     autoUpgrade = {
       enable = true;
       allowReboot = true;
       dates = "Mon *-*-* 06:00:00";
       persistent = true;
       randomizedDelaySec = "20min";
     };
   };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
