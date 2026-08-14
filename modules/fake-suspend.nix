
{ pkgs, ... }:

{
  services.hardware.openrgb.enable = true;
  powerManagement.cpufreq.max = null;

  systemd.services.systemd-suspend = {
    description = "Pseudo-Suspend (Server-Friendly Userspace Idle)";
    # Added 'niri' to the path so the script can use 'niri msg'
    path = with pkgs; [ procps openrgb linuxPackages.cpupower libinput gawk niri ];
    
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.writeShellScript "pseudo-suspend" ''
          # Define your user environment
          USERNAME="cig0073"
          USER_UID=$(id -u $USERNAME)
          export XDG_RUNTIME_DIR="/run/user/$USER_UID"
          export WAYLAND_DISPLAY="wayland-1"

          echo "Entering pseudo-suspend mode..."

          # 1. INHIBIT USER PROCESSES
          # We must NOT freeze niri, dbus, audio, or the tools running this script.
          # NOTE: If you run user-level servers (like syncthing or rootless podman), add them to this regex!
          EXCLUDE_REGEX="(niri|dbus|systemd|pipewire|wireplumber|polkit|bash|sudo|su|sleep|grep|libinput|syncthing)"
          
          # Find all PIDs owned by your user, filter out the safe list, and freeze the rest (games, browsers, etc.)
          pgrep -u $USERNAME | while read -r pid; do
             CMD=$(ps -p "$pid" -o comm= 2>/dev/null)
             if [[ -n "$CMD" ]] && ! echo "$CMD" | grep -qE "$EXCLUDE_REGEX"; then
                 kill -STOP "$pid" 2>/dev/null || true
             fi
          done

          # 2. KILL CASE LIGHTS
          openrgb --mode off || true

          # 3. THROTTLE POWER
          cpupower frequency-set -g powersave || true

          # 4. KILL DISPLAYS (NIRI)
          # Niri has a built-in IPC command to sleep the monitors.
          sudo -u $USERNAME XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR WAYLAND_DISPLAY=$WAYLAND_DISPLAY niri msg action power-off-monitors

          echo "System pseudo-suspended. Servers remaining online."

          # 5. WAIT FOR WAKEUP ACTION
          libinput debug-events | grep -q -m 1 -E "KEY_|POINTER_MOTION|POINTER_BUTTON"

          echo "Input detected. Waking up..."

          # 6. RESUME DISPLAYS (NIRI)
          sudo -u $USERNAME XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR WAYLAND_DISPLAY=$WAYLAND_DISPLAY niri msg action power-on-monitors

          # 7. RESTORE HARDWARE STATE
          cpupower frequency-set -g performance || true
          openrgb -p default || true

          # 8. RESUME USER PROCESSES
          pgrep -u $USERNAME | while read -r pid; do
             CMD=$(ps -p "$pid" -o comm= 2>/dev/null)
             if [[ -n "$CMD" ]] && ! echo "$CMD" | grep -qE "$EXCLUDE_REGEX"; then
                 kill -CONT "$pid" 2>/dev/null || true
             fi
          done

          echo "System fully resumed."
        ''}"
      ];
    };
  };
}
