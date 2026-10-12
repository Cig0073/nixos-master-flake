# gaming-jovian.nix — Jovian NixOS gaming profile (HTPC / Steam Deck-like)
{ lib, pkgs, ... }:
{
  system.activationScripts.print-jovian = {
    text = builtins.trace "building the jovian configuration..." "";
  };

  # ── Plymouth boot splash ──────────────────────────────────────────────────
  boot = {
    # Silent boot: hide kernel messages behind the splash
    consoleLogLevel = 3;
    initrd.verbose  = false;
    kernelParams    = [ "quiet" "rd.udev.log_level=3" "rd.systemd.show_status=auto" ];

    # Note: boot.plymouth is the correct attribute path (not top-level `plymouth`)
    plymouth = {
      enable        = true;
      theme         = "motion";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "motion" ];
        })
      ];
    };
  };

  # ── Jovian Steam (SteamOS-like experience) ───────────────────────────────
  jovian.steam = {
    enable         = true;
    autoStart      = true;
    desktopSession = "plasma-bigscreen-wayland";
    user           = "cig0073";
    environment.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "/run/current-system/sw/share/steam/compatibilitytools.d";
  };

  jovian.decky-loader = {
    enable = true;
    user   = "cig0073";
  };

  jovian.steamos.useSteamOSConfig = true;

  # Jovian configures its own pinned Gamescope wrapper, so disable nixpkgs' wrapper
  programs.gamescope.enable = lib.mkForce false;

  # ── Packages ──────────────────────────────────────────────────────────────
  # mangohud already provided by gaming.nix; only Jovian-specific extras here
  environment.systemPackages = with pkgs; [
    kdePackages.plasma-bigscreen
    kdePackages.plasma-keyboard
  ];

  services.orca.enable = true;
}
