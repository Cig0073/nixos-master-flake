# nixos-deck/default.nix
# Valve Steam Deck (LCD & OLED) running Jovian NixOS + Plasma Mobile + Retro Gaming
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # ── Steam Deck Hardware Integration (Jovian) ──────────────────────────────
  jovian.devices.steamdeck = {
    enable                     = true;
    enableKernelPatches        = false; # Use pre-built binary kernel from cache (no compiling from source)
    enableVendorDrivers        = false; # Use pre-built binary Mesa from cache
    enableSoundSupport         = true;
    enableOsFanControl         = true;
    enablePerfControlUdevRules = true;
    enableGyroDsuService       = true;
  };

  # Pre-compiled binary kernel from official cache
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── Jovian Steam Gaming Mode ───────────────────────────────────────────────
  jovian.steam = {
    enable         = true;
    autoStart      = true;
    desktopSession = lib.mkForce "plasma-mobile";
    user           = config.nixcore.username;
  };

  jovian.decky-loader = {
    enable = true;
    user   = config.nixcore.username;
  };

  jovian.steamos.useSteamOSConfig = true;

  # ── Desktop Mode: Plasma 6 Mobile ──────────────────────────────────────────
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sessionPackages = [ pkgs.kdePackages.plasma-mobile ];

  environment.systemPackages = with pkgs; [
    kdePackages.plasma-mobile
    kdePackages.plasma-keyboard
  ];

  # Give user a brief bootloader window to select retro specialisation
  boot.loader.timeout = lib.mkDefault 4;

  # ── Specialisation: Retro Gaming (Batocera Mode) ───────────────────────────
  # Exposes a separate boot entry in the bootloader that boots straight into
  # EmulationStation (ES-DE) in GameScope with native Quick Access Menu.
  specialisation.retro.configuration = {
    system.nixos.tags = [ "retro-gaming" ];

    # Disable Steam Big Picture autostart
    jovian.steam.autoStart = lib.mkForce false;

    # Boot straight into the custom GameScope retro session via SDDM
    services.displayManager = {
      defaultSession = lib.mkForce "retro-gaming";
      autoLogin = {
        enable = true;
        user   = config.nixcore.username;
      };
      sddm = {
        enable = true;
        autoLogin.relogin = true;
        wayland.enable    = true;
      };
    };
  };

  system.stateVersion = "26.05";
}
