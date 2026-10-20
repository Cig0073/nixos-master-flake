{ lib, writeShellScriptBin, fuzzel, procps, ryzenadj, brightnessctl, wireplumber, libnotify, systemd }:

writeShellScriptBin "deck-qam" ''
  export PATH="${lib.makeBinPath [ fuzzel procps ryzenadj brightnessctl wireplumber libnotify systemd ]}:$PATH"

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
      loginctl terminate-user "$USER" 2>/dev/null || notify-send "Switch to Desktop" "Session terminate requested"
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
''
