{ config, pkgs, ... }:
{
  # fake-suspend.nix — Server-friendly pseudo-suspend
  # Instead of real suspend (which would kill network), this:
  #   1. Freezes user processes (SIGSTOP)
  #   2. Kills case lights
  #   3. Throttles the CPU
  #   4. Turns off displays via Niri IPC
  #   5. Waits for keyboard/mouse input to wake up
  #   6. Restores everything
  #
  # Uncomment `# ./modules/fake-suspend.nix` in flake.nix to enable.

  services.hardware.openrgb.enable = true;
  powerManagement.cpufreq.max      = null;

  systemd.services.systemd-suspend = {
    description = "Pseudo-Suspend (Server-Friendly Userspace Idle)";
    path = with pkgs; [
      procps openrgb linuxPackages.cpupower libinput gawk niri
    ];

    serviceConfig.ExecStart = [
      ""  # Clear the default ExecStart
      (pkgs.writeShellScript "pseudo-suspend" ''
        USERNAME="${config.nixcore.username}"
        USER_UID=$(id -u "$USERNAME")
        export XDG_RUNTIME_DIR="/run/user/$USER_UID"
        export WAYLAND_DISPLAY="wayland-1"

        echo "Entering pseudo-suspend mode..."

        # Processes that must NOT be frozen (add user-level servers like syncthing here)
        EXCLUDE_REGEX="(niri|dbus|systemd|pipewire|wireplumber|polkit|bash|sudo|su|sleep|grep|libinput|syncthing)"

        _freeze() {
          pgrep -u "$USERNAME" | while read -r pid; do
            CMD=$(ps -p "$pid" -o comm= 2>/dev/null)
            if [[ -n "$CMD" ]] && ! echo "$CMD" | grep -qE "$EXCLUDE_REGEX"; then
              kill -"$1" "$pid" 2>/dev/null || true
            fi
          done
        }

        # 1. Freeze user processes
        _freeze STOP

        # 2. Kill case lights
        openrgb --mode off || true

        # 3. Throttle CPU
        cpupower frequency-set -g powersave || true

        # 4. Turn off displays (Niri IPC)
        sudo -u "$USERNAME" \
          XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
          WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
          niri msg action power-off-monitors

        echo "System pseudo-suspended. Servers remaining online."

        # 5. Wait for any keyboard/mouse input
        libinput debug-events | grep -q -m 1 -E "KEY_|POINTER_MOTION|POINTER_BUTTON"

        echo "Input detected. Waking up..."

        # 6. Restore displays
        sudo -u "$USERNAME" \
          XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
          WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
          niri msg action power-on-monitors

        # 7. Restore hardware
        cpupower frequency-set -g performance || true
        openrgb -p default || true

        # 8. Resume user processes
        _freeze CONT

        echo "System fully resumed."
      '')
    ];
  };
}
