{ writeShellScriptBin, gamescope, pegasus-frontend, retroarch-full }:

writeShellScriptBin "retro-session" ''
  export MANGOHUD=1
  export MANGOHUD_CONFIG="output_folder=/tmp,toggle_hud=Shift_R+F12,position=top-left,battery,fps,frametime=0"

  if command -v es-de >/dev/null 2>&1; then
    FRONTEND_CMD="es-de"
  elif flatpak list 2>/dev/null | grep -q "org.es_de.emulationstation-de"; then
    FRONTEND_CMD="flatpak run org.es_de.emulationstation-de"
  elif command -v pegasus-frontend >/dev/null 2>&1; then
    FRONTEND_CMD="pegasus-frontend"
  else
    FRONTEND_CMD="${retroarch-full}/bin/retroarch"
  fi

  # Support --windowed for desktop testing without fullscreen takeover
  if [ "$1" = "--windowed" ] || [ "$1" = "-w" ]; then
    echo "Starting GameScope in a nested 1280x800 desktop window..."
    exec ${gamescope}/bin/gamescope \
      -w 1280 \
      -h 800 \
      -W 1280 \
      -H 800 \
      -- $FRONTEND_CMD
  else
    exec ${gamescope}/bin/gamescope \
      -e \
      -f \
      -w 1280 \
      -h 800 \
      -r 60 \
      --force-grab-cursor \
      -- $FRONTEND_CMD
  fi
''
