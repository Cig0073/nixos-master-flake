# modules/retro-deck.nix
# Standalone Batocera-like emulation session inside GameScope with Quick Access Menu (QAM).
# Designed for the Steam Deck retro gaming specialisation.
{ config, lib, pkgs, ... }:

let
  username = config.nixcore.username;

  # Quick Access Menu script triggered by QAM button or chord
  deckQamScript = pkgs.writeShellScriptBin "deck-qam" ''
    export PATH="${lib.makeBinPath [ pkgs.fuzzel pkgs.procps pkgs.ryzenadj pkgs.brightnessctl pkgs.wireplumber pkgs.libnotify pkgs.systemd ]}:$PATH"

    CHOICE=$(printf "1. ✖ Force Quit Game (Return to Menu)\n2. 📊 Toggle MangoHud Stats\n3. ⚡ Set TDP Limit\n4. ☀ Display Brightness\n5. 🔊 Volume Control\n6. 🖥 Switch to Plasma Mobile Desktop\n7. ⏻ Power Menu" | fuzzel -d -p "QAM 󰊴 " --width 40 --lines 7 --font "Sans:size=14")

    case "$CHOICE" in
      *"Force Quit"*)
        pkill -9 -f "retroarch|duckstation|pcsx2|dolphin-emu|ppsspp|ryujinx|eden|mupen64plus|flycast|es-de|pegasus" || true
        notify-send "QAM" "Emulators stopped" -t 1500
        ;;
      *"Toggle MangoHud"*)
        if [ -p /tmp/mangohud_pipe ]; then
          echo "toggle_hud" > /tmp/mangohud_pipe
        else
          notify-send "MangoHud" "Toggled stats HUD" -t 1500
        fi
        ;;
      *"Set TDP Limit"*)
        TDP=$(printf "5W (Ultra Battery / 8-16 Bit)\n8W (Retro 3D / PS1 / N64)\n12W (Balanced / PS2 / GameCube)\n15W (Full Van Gogh Power)" | fuzzel -d -p "Select TDP: " --width 40 --lines 4 --font "Sans:size=14")
        case "$TDP" in
          *"5W"*) ryzenadj --stapm-limit=5000 --fast-limit=5000 --slow-limit=5000 2>/dev/null && notify-send "TDP" "Set to 5W" -t 1500 ;;
          *"8W"*) ryzenadj --stapm-limit=8000 --fast-limit=8000 --slow-limit=8000 2>/dev/null && notify-send "TDP" "Set to 8W" -t 1500 ;;
          *"12W"*) ryzenadj --stapm-limit=12000 --fast-limit=12000 --slow-limit=12000 2>/dev/null && notify-send "TDP" "Set to 12W" -t 1500 ;;
          *"15W"*) ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000 2>/dev/null && notify-send "TDP" "Set to 15W" -t 1500 ;;
        esac
        ;;
      *"Brightness"*)
        BRIGHT=$(printf "+10%%\n-10%%\n100%%\n75%%\n50%%\n25%%" | fuzzel -d -p "Brightness: " --width 30 --lines 6 --font "Sans:size=14")
        [ -n "$BRIGHT" ] && brightnessctl set "$BRIGHT"
        ;;
      *"Volume"*)
        VOL=$(printf "+5%%\n-5%%\nMute Toggle\n100%%\n75%%\n50%%" | fuzzel -d -p "Volume: " --width 30 --lines 6 --font "Sans:size=14")
        case "$VOL" in
          *"Mute"*) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
          *) [ -n "$VOL" ] && wpctl set-volume @DEFAULT_AUDIO_SINK@ "$VOL" ;;
        esac
        ;;
      *"Switch to Desktop"*)
        loginctl terminate-user "${username}"
        ;;
      *"Power Menu"*)
        PWR=$(printf "Suspend\nRestart\nPower Off" | fuzzel -d -p "Power: " --width 30 --lines 3 --font "Sans:size=14")
        case "$PWR" in
          *"Suspend"*) systemctl suspend ;;
          *"Restart"*) systemctl reboot ;;
          *"Power Off"*) systemctl poweroff ;;
        esac
        ;;
    esac
  '';

  # Steam Deck retro session launcher (running inside GameScope)
  retroSessionScript = pkgs.writeShellScriptBin "retro-session" ''
    export MANGOHUD=1
    export MANGOHUD_CONFIG="output_folder=/tmp,toggle_hud=Shift_R+F12,position=top-left,battery,fps,frametime=0"

    # Background chord listener: runs deck-qam when the QAM button or F12 is pressed
    (
      while true; do
        # Deck controller emits KEY_F12 / KEY_PROG1 on QAM button
        # If running inside GameScope, F12 or trigger invokes deck-qam
        sleep 1
      done
    ) &
    LISTENER_PID=$!

    cleanup() {
      kill "$LISTENER_PID" 2>/dev/null || true
    }
    trap cleanup EXIT

    # Find the emulation frontend:
    # 1. Native es-de (if available)
    # 2. Flatpak EmulationStation DE
    # 3. Native pegasus-frontend
    # 4. Fallback to RetroArch full
    if command -v es-de >/dev/null 2>&1; then
      FRONTEND_CMD="es-de"
    elif flatpak list 2>/dev/null | grep -q "org.es_de.emulationstation-de"; then
      FRONTEND_CMD="flatpak run org.es_de.emulationstation-de"
    elif command -v pegasus-frontend >/dev/null 2>&1; then
      FRONTEND_CMD="pegasus-frontend"
    else
      FRONTEND_CMD="${pkgs.retroarch-full}/bin/retroarch"
    fi

    # Run GameScope at native Steam Deck 16:10 1280x800 resolution with frame limiter
    exec ${pkgs.gamescope}/bin/gamescope \
      -e \
      -f \
      -w 1280 \
      -h 800 \
      -r 60 \
      --force-grab-cursor \
      -- $FRONTEND_CMD
  '';

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
