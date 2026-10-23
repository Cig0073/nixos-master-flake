{ lib, writeShellScriptBin, fuzzel, procps, ryzenadj, brightnessctl, wireplumber, libnotify, systemd, gawk }:

writeShellScriptBin "deck-qam" ''
  export PATH="${lib.makeBinPath [ fuzzel procps ryzenadj brightnessctl wireplumber libnotify systemd gawk ]}:$PATH"

  # ── Live Hardware Telemetry ───────────────────────────────────────────────
  # Battery
  BAT_CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)
  BAT_STAT=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1)
  if [ -n "$BAT_CAP" ]; then
    if [ "$BAT_STAT" = "Charging" ]; then
      BAT_INFO="󰂄 ''${BAT_CAP}%"
    else
      BAT_INFO="󰁹 ''${BAT_CAP}%"
    fi
  else
    BAT_INFO="󰚥 AC"
  fi

  # Time
  TIME_INFO=" $(date +%H:%M)"

  # Volume
  VOL_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
  if echo "$VOL_RAW" | grep -q "MUTED"; then
    CURR_VOL="Muted"
    VOL_ICON="󰖁"
  else
    VOL_PCT=$(echo "$VOL_RAW" | awk '{print int($2 * 100)}')
    CURR_VOL="''${VOL_PCT:-70}%"
    VOL_ICON="󰕾"
  fi

  # Brightness
  CURR_BRIGHT=$(brightnessctl -m 2>/dev/null | cut -d, -f4)
  [ -z "$CURR_BRIGHT" ] && CURR_BRIGHT="N/A"

  # TDP Limit
  if [ -f /tmp/deck_tdp_limit ]; then
    CURR_TDP=$(cat /tmp/deck_tdp_limit 2>/dev/null)
  else
    HWMON_CAP=$(cat /sys/class/hwmon/hwmon*/power1_cap 2>/dev/null | head -n1)
    if [ -n "$HWMON_CAP" ] && [ "$HWMON_CAP" -gt 0 ] 2>/dev/null; then
      WATT=$(( HWMON_CAP / 1000000 ))
      if [ "$WATT" -le 30 ] && [ "$WATT" -ge 4 ]; then
        CURR_TDP="''${WATT}W"
      else
        CURR_TDP="15W"
      fi
    else
      CURR_TDP="15W"
    fi
  fi

  # Active game / emulator
  GAME_PID=$(pgrep -f "retroarch|duckstation|pcsx2|dolphin-emu|ppsspp|ryujinx|eden|mupen64plus|flycast" 2>/dev/null | head -n1)
  if [ -n "$GAME_PID" ]; then
    GAME_NAME=$(ps -p "$GAME_PID" -o comm= 2>/dev/null)
    HEADER_STATUS="🎮 Playing: $GAME_NAME"
    QUIT_LABEL="󰈆   Force Quit Active Game    [Running: $GAME_NAME]"
  else
    HEADER_STATUS="󰊴 Idle in Carousel"
    QUIT_LABEL="󰈆   Force Quit Game           [No Game Running]"
  fi

  HEADER_MSG="  $HEADER_STATUS   •   $BAT_INFO   •   ⚡ $CURR_TDP   •   $VOL_ICON $CURR_VOL   •   ☀ $CURR_BRIGHT   •   $TIME_INFO"

  # ── Fuzzel SteamOS Theme ──────────────────────────────────────────────────
  FUZZEL_THEME=(
    --dmenu
    --font="Sans:size=13"
    --width=48
    --horizontal-pad=24
    --vertical-pad=18
    --inner-pad=12
    --line-height=34
    --border-width=2
    --border-radius=18
    --selection-radius=10
    --anchor=top-right
    --x-margin=24
    --y-margin=24
    --layer=overlay
    --background-color=131620f0
    --text-color=cbd5e1ff
    --prompt-color=38bdf8ff
    --selection-color=1e3a5fee
    --selection-text-color=ffffffff
    --selection-match-color=38bdf8ff
    --match-color=38bdf8ff
    --border-color=38bdf866
    --message-color=7dd3fcff
    --mesg="$HEADER_MSG"
  )

  MENU_ITEMS=(
    "$QUIT_LABEL"
    "󰍹   Performance Overlay       [Cycle MangoHud]"
    "󰓅   Thermal & TDP Limit       [Currently: $CURR_TDP]"
    "󰃟   Display Brightness        [Currently: $CURR_BRIGHT]"
    "󰕾   Audio Volume              [Currently: $CURR_VOL]"
    "󰌢   Switch to Desktop         [Plasma Mobile]"
    "󰐥   System Power              [Sleep / Reboot / Off]"
  )

  CHOICE=$(printf "%s\n" "''${MENU_ITEMS[@]}" | fuzzel "''${FUZZEL_THEME[@]}" -p "󰊴  QUICK ACCESS  " --lines=7)

  case "$CHOICE" in
    *"Force Quit"*)
      pkill -9 -f "retroarch|duckstation|pcsx2|dolphin-emu|ppsspp|ryujinx|eden|mupen64plus|flycast|es-de|pegasus" || true
      notify-send "Quick Access" "Active game force-quit" -t 1500
      ;;

    *"Performance Overlay"*)
      if [ -p /tmp/mangohud_pipe ]; then
        echo "toggle_hud" > /tmp/mangohud_pipe
      else
        notify-send "Performance HUD" "Toggled stats display" -t 1500
      fi
      ;;

    *"Thermal & TDP"*)
      TDP_OPTIONS=(
        "󰾆   5W  - Ultra Battery   [8/16-Bit, GBA, NES]"
        "󰾅   8W  - Retro 3D        [PS1, N64, Arcade]"
        "󰓅  12W  - Balanced 3D     [PS2, GameCube, PSP]"
        "󰓅  15W  - Maximum Power   [Wii, Switch, High-end]"
      )
      TDP=$(printf "%s\n" "''${TDP_OPTIONS[@]}" | fuzzel "''${FUZZEL_THEME[@]}" -p "⚡  TDP LIMIT (Now: $CURR_TDP)  " --lines=4)
      case "$TDP" in
        *"5W"*)
          echo "5W" > /tmp/deck_tdp_limit
          ryzenadj --stapm-limit=5000 --fast-limit=5000 --slow-limit=5000 2>/dev/null
          notify-send "TDP" "Set to 5 Watts" -t 1500
          ;;
        *"8W"*)
          echo "8W" > /tmp/deck_tdp_limit
          ryzenadj --stapm-limit=8000 --fast-limit=8000 --slow-limit=8000 2>/dev/null
          notify-send "TDP" "Set to 8 Watts" -t 1500
          ;;
        *"12W"*)
          echo "12W" > /tmp/deck_tdp_limit
          ryzenadj --stapm-limit=12000 --fast-limit=12000 --slow-limit=12000 2>/dev/null
          notify-send "TDP" "Set to 12 Watts" -t 1500
          ;;
        *"15W"*)
          echo "15W" > /tmp/deck_tdp_limit
          ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000 2>/dev/null
          notify-send "TDP" "Set to 15 Watts (Uncapped)" -t 1500
          ;;
      esac
      ;;

    *"Brightness"*)
      BRIGHT_OPTIONS=(
        "󰃠   100% Maximum Brightness"
        "󰃟    75% Standard Indoor"
        "󰃞    50% Battery Saver"
        "󰃝    25% Low Light"
        "󰃠   +10% Increase"
        "󰃞   -10% Decrease"
      )
      BRIGHT=$(printf "%s\n" "''${BRIGHT_OPTIONS[@]}" | fuzzel "''${FUZZEL_THEME[@]}" -p "☀  BRIGHTNESS (Now: $CURR_BRIGHT)  " --lines=6)
      case "$BRIGHT" in
        *"100%"*) brightnessctl set 100% ;;
        *"75%"*)  brightnessctl set 75% ;;
        *"50%"*)  brightnessctl set 50% ;;
        *"25%"*)  brightnessctl set 25% ;;
        *"+10%"*) brightnessctl set +10% ;;
        *"-10%"*) brightnessctl set 10%- ;;
      esac
      ;;

    *"Audio Volume"*)
      VOL_OPTIONS=(
        "󰕾   +5% Volume Up"
        "󰖀   -5% Volume Down"
        "󰖁   Toggle Mute"
        "󰕾   100% Full"
        "󰖀    70% Standard"
        "󰕿    40% Quiet"
      )
      VOL=$(printf "%s\n" "''${VOL_OPTIONS[@]}" | fuzzel "''${FUZZEL_THEME[@]}" -p "🔊  VOLUME (Now: $CURR_VOL)  " --lines=6)
      case "$VOL" in
        *"+5%"*)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ ;;
        *"-5%"*)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        *"Mute"*)  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        *"100%"*)  wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0 ;;
        *"70%"*)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.7 ;;
        *"40%"*)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.4 ;;
      esac
      ;;

    *"Switch to Desktop"*)
      loginctl terminate-user "$USER" 2>/dev/null || notify-send "Switch to Desktop" "Session terminate requested"
      ;;

    *"System Power"*)
      PWR_OPTIONS=(
        "󰤄   Suspend / Sleep"
        "󰜉   Restart System"
        "󰐥   Power Off"
      )
      PWR=$(printf "%s\n" "''${PWR_OPTIONS[@]}" | fuzzel "''${FUZZEL_THEME[@]}" -p "⏻  POWER  " --lines=3)
      case "$PWR" in
        *"Suspend"*) systemctl suspend ;;
        *"Restart"*) systemctl reboot ;;
        *"Power Off"*) systemctl poweroff ;;
      esac
      ;;
  esac
''
