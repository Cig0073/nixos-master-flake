# modules/options.nix
# Centralized configuration options and parameters for NixCore.
# Allows easily overriding user names, paths, domains, and addresses in one place.
{ lib, config, ... }:
with lib;
{
  options.nixcore = {
    username = mkOption {
      type        = types.str;
      default     = "cig0073";
      description = "Primary user account name across all machines.";
    };

    userHome = mkOption {
      type        = types.path;
      default     = "/home/${config.nixcore.username}";
      description = "Absolute path to the primary user's home directory.";
    };

    tailnetDomain = mkOption {
      type        = types.str;
      default     = "nixos.tail8a17d2.ts.net";
      description = "Tailscale domain for self-hosted services (Nextcloud, Vault).";
    };

    saveBackupDir = mkOption {
      type        = types.str;
      default     = "${config.nixcore.userHome}/Backups/SaveGames";
      description = "Default destination directory for game save backups (Ludusavi).";
    };

    vaultStorageDir = mkOption {
      type        = types.str;
      default     = "/mnt/vault-storage";
      description = "Primary persistent mount path for homelab data (Nextcloud, Immich).";
    };

    sunshineOrigin = mkOption {
      type        = types.str;
      default     = "https://192.168.0.12";
      description = "Allowed web UI / CSRF origin for Sunshine game streaming.";
    };
  };
}
