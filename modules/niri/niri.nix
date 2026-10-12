{ pkgs, ... }:
let
  defaultDmsConfig = ./dms-settings.json;
in
{
  programs.niri.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # ── dms-shell (composited session manager) ────────────────────────────────
  programs.dms-shell = {
    enable = true;
    systemd = {
      enable           = true;
      restartIfChanged = true;
    };
  };

  # ── Display manager ───────────────────────────────────────────────────────
  services.displayManager = {
    dms-greeter = {
      enable         = true;
      compositor.name = "niri";
      configHome     = "/home/cig0073";
    };
    autoLogin = {
      enable = true;
      user   = "cig0073";
    };
    defaultSession = "niri";
  };

  # ── Extras ────────────────────────────────────────────────────────────────
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    nautilus
    nautilus-python
  ];

  services.gvfs.enable    = true;
  services.gnome.sushi.enable = true;
  services.udisks2.enable = true;

  # ── Home Manager: deploy niri config and seed dms config ─────────────────
  home-manager.sharedModules = [
    ({ config, lib, ... }: {
      xdg.configFile."niri/config.kdl" = {
        source = ./config.kdl;
        force  = true;
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
