{ pkgs, ... }:
let
  # Path to your default config (can be a relative file in your repo or inline text)
  defaultDmsConfig = ./dms-settings.json; 
  # Or inline: pkgs.writeText "dms-config.json" ''{ "theme": "dark" }'';
in
{
  programs.niri.enable = true;
  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service

  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true;             # Systemd service for auto-start
      restartIfChanged = true;   # Auto-restart dms.service when dms-shell changes
    };
  
    # Core features
    enableSystemMonitoring = true;     # System monitoring widgets (dgop)
    enableVPN = true;                  # VPN management widget
    enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
    enableAudioWavelength = true;      # Audio visualizer (cava)
    enableCalendarEvents = true;       # Calendar integration (khal)
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";  # Or "hyprland" or "sway"
    configHome = "/home/cig0073";
  };

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "cig0073";
    };
    defaultSession = "niri";
  };
  programs.kdeconnect = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [ xwayland-satellite ];

  # Applies to all Home Manager profiles on this machine
  home-manager.sharedModules = [
    #  Explicitly request Home Manager's scope here
    ({ config, lib, ... }: {
      
      xdg.configFile."niri/config.kdl" = {
        source = ./config.kdl;
        force = true;
      };

      home.activation.initDmsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        TARGET_DIR="$HOME/.config/dms"
        TARGET_FILE="$TARGET_DIR/config.json"

        $DRY_RUN_CMD mkdir -p "$TARGET_DIR"

        if [ ! -e "$TARGET_FILE" ]; then
          $DRY_RUN_CMD cp ${defaultDmsConfig} "$TARGET_FILE"
          $DRY_RUN_CMD chmod 644 "$TARGET_FILE"
        fi
      '';

    })
  ];
}
