# gaming-liberated.nix — DRM-free / GOG / pirate-friendly gaming stack
{ config, pkgs, lib, ... }:

let
  targetUser = config.nixcore.username;
  backupDir  = config.nixcore.saveBackupDir;

  # Automated Ludusavi backup with desktop notifications
  ludusaviAutoBackup = pkgs.writeShellScriptBin "ludusavi-auto-backup" ''
    set -euo pipefail

    USER_ID=$(${pkgs.coreutils}/bin/id -u "${targetUser}")
    export XDG_RUNTIME_DIR="/run/user/$USER_ID"
    export HOME="/home/${targetUser}"

    ${pkgs.coreutils}/bin/mkdir -p "${backupDir}"

    LOG_FILE="/tmp/ludusavi-backup.log"

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

  # Wrap hydra-launcher to supply runtime PATH + Proton compat paths
  hydraLauncherWrapped = pkgs.symlinkJoin {
    name              = "hydra-launcher-wrapped";
    paths             = [ pkgs.hydralauncher ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
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

      if [ -d "$out/share/applications" ]; then
        for f in $out/share/applications/*.desktop; do
          cp --remove-destination "$(readlink -f "$f")" "$f"
          sed -i "s|^Exec=.*|Exec=$out/bin/hydralauncher %U|" "$f"
        done
      fi
    '';
  };
in
{
  # ── Packages ──────────────────────────────────────────────────────────────
  # Note: lutris and gamemode are already provided by gaming.nix
  environment.systemPackages = with pkgs; [
    hydraLauncherWrapped
    ludusavi
    ludusaviAutoBackup
    protontricks  # Missing DLLs (DirectX, VCRedist, PhysX, XACT)
    winetricks
    heroic
    umu-launcher
  ];

  # ── Triple-lock automatic save backups ────────────────────────────────────

  # 1. On game exit — GameMode triggers this instantly when a game closes
  programs.gamemode.settings.custom.end =
    "${ludusaviAutoBackup}/bin/ludusavi-auto-backup";

  # 2. On sleep / shutdown — backs up before the system goes offline
  systemd.services.ludusavi-pre-suspend = {
    description = "Backup Game Saves Before System Sleep or Shutdown";
    wantedBy    = [ "sleep.target" "shutdown.target" ];
    before      = [ "sleep.target" "shutdown.target" ];
    serviceConfig = {
      Type      = "oneshot";
      ExecStart = "${ludusaviAutoBackup}/bin/ludusavi-auto-backup";
    };
  };
}
