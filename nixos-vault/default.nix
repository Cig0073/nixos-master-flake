{ config, pkgs, ... }:
{
  imports = [
    # vault runs on chell's hardware profile and inherits its base setup
    ../nixos-chell/default.nix
    ./filesystems.nix
  ];

  # ── GPU: ROCm (AMD OpenCL/HIP) ────────────────────────────────────────────
  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr ];

  # ── AI: Ollama with ROCm acceleration ─────────────────────────────────────
  services.ollama = {
    enable     = true;
    package    = pkgs.ollama-rocm;
    loadModels = [ "qwen2.5:3b" ];
  };

  # ── Containerisation ──────────────────────────────────────────────────────
  virtualisation.podman = {
    enable       = true;
    dockerCompat = true;
  };

  users.users.${config.nixcore.username}.extraGroups = [ "render" "video" "podman" ];

  # ── Media: Immich ─────────────────────────────────────────────────────────
  services.immich = {
    enable        = true;
    host          = "0.0.0.0";
    port          = 2283;
    openFirewall  = true;
    mediaLocation = "${config.nixcore.vaultStorageDir}/immich";
  };

  # ── Cloud: Nextcloud (served over Tailscale) ──────────────────────────────
  services.nextcloud = {
    enable             = true;
    hostName           = config.nixcore.tailnetDomain;
    home               = "${config.nixcore.vaultStorageDir}/nextcloud";
    database.createLocally = true;
    configureRedis     = true;
    maxUploadSize      = "10G";
    config = {
      adminuser     = "admin";
      adminpassFile = "/var/lib/nextcloud/admin-pass";
      dbtype        = "pgsql";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 2283 ];
}
