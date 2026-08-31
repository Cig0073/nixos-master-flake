
# /etc/nixos/modules/gaming-liberated.nix
{ pkgs, lib, ... }:

let
  targetUser = "cig0073";
  backupDir = "/home/${targetUser}/Backups/SaveGames";

  # Automated Ludusavi backup runner with desktop notifications
  ludusaviAutoBackup = pkgs.writeShellScriptBin "ludusavi-auto-backup" ''
    set -euo pipefail

    USER_ID=$(${pkgs.coreutils}/bin/id -u "${targetUser}")
    export XDG_RUNTIME_DIR="/run/user/$USER_ID"
    export HOME="/home/${targetUser}"

    # Ensure local backup directory exists
    ${pkgs.coreutils}/bin/mkdir -p "${backupDir}"

    LOG_FILE="/tmp/ludusavi-backup.log"

    # Run headless Ludusavi backup
    if ${pkgs.ludusavi}/bin/ludusavi backup --force --path "${backupDir}" > "$LOG_FILE" 2>&1; then
      ${pkgs.libnotify}/bin/notify-send -u low -a "Ludusavi" \
        "Saves Backed Up" \
        "Game saves successfully saved to ${backupDir}" -i drive-harddisk || true
    else
      ${pkgs.libnotify}/bin/notify-send -u normal -a "Ludusavi" \
        "Save Backup Notice" \
        "Backup completed with warnings. Check $LOG_FILE" -i dialog-warning || true
    fi
  '';

  # Wrap nixpkgs' hydra-launcher to supply runtime PATH dependencies
  hydraLauncherWrapped = pkgs.symlinkJoin {
    name = "hydra-launcher-wrapped";
    paths = [ pkgs.hydralauncher ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # 1. Wrap the binary with PATH and Proton compatibility paths
      wrapProgram $out/bin/hydralauncher \
        --prefix PATH : ${lib.makeBinPath [
          pkgs.umu-launcher
          pkgs.python3
          pkgs.bash
          pkgs.coreutils
          pkgs.vulkan-tools
          pkgs.zenity
          pkgs.gamemode
        ]} \
        --prefix STEAM_EXTRA_COMPAT_TOOLS_PATHS : "${pkgs.proton-ge-custom}:${pkgs.proton-cachyos}"

      # 2. Copy the .desktop file and dynamically substitute any Exec= line
      if [ -d "$out/share/applications" ]; then
        for f in $out/share/applications/*.desktop; do
          cp --remove-destination "$(readlink -f "$f")" "$f"
          # Replaces 'Exec=<whatever>' with 'Exec=$out/bin/hydralauncher <flags>'
          sed -i "s|^Exec=.*|Exec=$out/bin/hydralauncher %U|" "$f"
        done
      fi
    '';
  };
in
{
  # Install the liberated gaming stack
  environment.systemPackages = with pkgs; [
    hydraLauncherWrapped
    ludusavi
    ludusaviAutoBackup
    
    # Crucial utilities for pirate repacks needing missing DLLs (DirectX, VCRedist, PhysX, XACT)
    protontricks
    winetricks
    heroic
    lutris
    umu-launcher
  ];

  # Enable GameMode
  programs.gamemode.enable = true;

  # --- TRIPLE-LOCK AUTOMATIC SAVE BACKUPS ---

  # 1. TRIGGER ON GAME EXIT: GameMode runs this script instantly when a game closes
  programs.gamemode.settings = {
    custom = {
      end = "${ludusaviAutoBackup}/bin/ludusavi-auto-backup";
    };
  };

  # 2. TRIGGER ON SLEEP / SHUTDOWN: Backs up saves before system sleep or shutdown
  systemd.services.ludusavi-pre-suspend = {
    description = "Backup Game Saves Before System Sleep or Shutdown";
    wantedBy = [ "sleep.target" "shutdown.target" ];
    before = [ "sleep.target" "shutdown.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${ludusaviAutoBackup}/bin/ludusavi-auto-backup";
    };
  };
}
