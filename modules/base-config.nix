{ pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  programs.nix-index-database.comma.enable = true;

  # ── Nix daemon ────────────────────────────────────────────────────────────
  nix = {
    settings.experimental-features = [
      "nix-command"         # Modern 'nix' CLI (nix shell, nix run, …)
      "flakes"              # Lockfile-reproducible system setups
      "ca-derivations"      # Content-addressed store (deduplication)
      "auto-allocate-uids"  # Dynamic UIDs for sandboxed builds
      "impure-derivations"  # Derivations that access outside context
      "recursive-nix"       # Nested Nix builds inside a derivation
    ];

    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 60d";
    };
  };

  # ── Locale / Time ─────────────────────────────────────────────────────────
  time.timeZone = "Europe/Istanbul";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS        = "tr_TR.UTF-8";
      LC_IDENTIFICATION = "tr_TR.UTF-8";
      LC_MEASUREMENT    = "tr_TR.UTF-8";
      LC_MONETARY       = "tr_TR.UTF-8";
      LC_NAME           = "tr_TR.UTF-8";
      LC_NUMERIC        = "tr_TR.UTF-8";
      LC_PAPER          = "tr_TR.UTF-8";
      LC_TELEPHONE      = "tr_TR.UTF-8";
      LC_TIME           = "tr_TR.UTF-8";
    };
  };

  # ── Graphics ──────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable     = true;
    enable32Bit = true;
  };

  # ── Networking ────────────────────────────────────────────────────────────
  networking = {
    firewall.enable = true;

    # Use iwd as the Wi-Fi backend for lower latency
    networkmanager = {
      enable       = true;
      wifi.backend = "iwd";
      wifi.powersave = false; # Keeps Wi-Fi chip out of low-power states
    };

    # iwd: disable background scanning to reduce unexpected latency spikes
    wireless.iwd.settings = {
      Scan.DisablePeriodicScan = true;
      Settings.AutoConnect     = true;
    };
  };

  # ── Services ──────────────────────────────────────────────────────────────
  services = {
    upower.enable   = true;
    printing.enable = true;
    libinput.enable = true; # Touchpad support

    openssh.enable = true;

    # Audio: PipeWire (PulseAudio disabled)
    pulseaudio.enable = false;
    pipewire = {
      enable           = true;
      alsa.enable      = true;
      alsa.support32Bit = true;
      pulse.enable     = true;
    };
  };

  security.rtkit.enable = true;

  # ── Shell ─────────────────────────────────────────────────────────────────
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      fastfetch
    '';
  };

  # ── User ──────────────────────────────────────────────────────────────────
  users.users.cig0073 = {
    isNormalUser = true;
    extraGroups  = [ "networkmanager" "wheel" "video" "input" "uinput" ];
    shell        = pkgs.fish;
  };

  # ── Swap ──────────────────────────────────────────────────────────────────
  zramSwap = {
    enable        = true;
    memoryPercent = 100;
    algorithm     = "zstd";
    priority      = 5;
  };

  # ── Packages ──────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    helix
    git
    wget
    tldr
    wl-clipboard
    fastfetch
    comma
  ];

  # ── Activation: diff current ↔ new generation ──────────────────────────
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff \
        /run/current-system "$systemConfig"
    '';
  };
}
