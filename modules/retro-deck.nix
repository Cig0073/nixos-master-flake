# modules/retro-deck.nix
# Standalone Batocera-like emulation session inside GameScope with Quick Access Menu (QAM).
# Designed for the Steam Deck retro gaming specialisation.
{ config, lib, pkgs, ... }:

let
  username = config.nixcore.username;

  deckQamScript = pkgs.callPackage ../pkgs/deck-qam.nix { };
  retroSessionScript = pkgs.callPackage ../pkgs/retro-session.nix { };

  retroDesktopItem = (pkgs.writeTextDir "share/wayland-sessions/retro-gaming.desktop" ''
    [Desktop Entry]
    Name=Retro Gaming (Batocera Mode)
    Comment=Direct GameScope EmulationStation Session
    Exec=${retroSessionScript}/bin/retro-session
    Type=Application
    DesktopNames=GameScope
  '') // {
    providedSessions = [ "retro-gaming" ];
  };
in
{
  # Install frontends, tools, and the QAM script system-wide
  environment.systemPackages = with pkgs; [
    deckQamScript
    retroSessionScript
    pegasus-frontend
    retroarch-full
    fuzzel
    brightnessctl
    ryzenadj
    wireplumber
    libnotify
  ];

  # Provide the retro-gaming wayland session to SDDM / DisplayManager
  services.displayManager.sessionPackages = [ retroDesktopItem ];

  # Flatpak enabled so users can install ES-DE from flathub if desired
  services.flatpak.enable = true;

  # Create standard Batocera/EmuDeck directory layout in home
  systemd.user.tmpfiles.users.${username}.rules = [
    "d %h/Emulation/roms 0755 - - -"
    "d %h/Emulation/bios 0755 - - -"
    "d %h/Emulation/saves 0755 - - -"
    "d %h/Emulation/storage 0755 - - -"
  ];
}
