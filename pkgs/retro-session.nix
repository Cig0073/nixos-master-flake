{ writeShellScriptBin, gamescope, pegasus-frontend, retroarch-full }:

writeShellScriptBin "retro-session" ''
  export MANGOHUD=1
  export MANGOHUD_CONFIG="output_folder=/tmp,toggle_hud=Shift_R+F12,position=top-left,battery,fps,frametime=0"
  # Pegasus frontend uses Qt5 without QtWayland plugins; use Gamescope's Xwayland server (xcb)
  export QT_QPA_PLATFORM=xcb

  # Prefer privileged capabilities wrapper if running on system
  GAMESCOPE_BIN="/run/wrappers/bin/gamescope"
  if [ ! -x "$GAMESCOPE_BIN" ]; then
    GAMESCOPE_BIN="${gamescope}/bin/gamescope"
  fi

  FRONTEND_BIN="${pegasus-frontend}/bin/pegasus-fe"

  # Support --windowed for desktop testing without fullscreen takeover
  if [ "$1" = "--windowed" ] || [ "$1" = "-w" ]; then
    echo "Starting Pegasus Frontend in a nested 1280x800 desktop window..."
    exec "$GAMESCOPE_BIN" \
      -w 1280 \
      -h 800 \
      -W 1280 \
      -H 800 \
      --expose-wayland \
      -- "$FRONTEND_BIN"
  else
    # Fullscreen standalone DRM/KMS mode on Steam Deck
    # Note: Do NOT use -e (--steam) here since Pegasus runs standalone without Steam
    exec "$GAMESCOPE_BIN" \
      -f \
      -w 1280 \
      -h 800 \
      -r 60 \
      --force-grab-cursor \
      --expose-wayland \
      -- "$FRONTEND_BIN"
  fi
''
