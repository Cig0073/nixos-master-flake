{ pkgs, config, ... }:

let
  tailnetDomain = "nixos.tail8a17d2.ts.net";
in
{
  imports = [ ./filesystems.nix ];

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
  ];

  services.tailscale.enable = true;

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    openFirewall = true;
    mediaLocation = "/mnt/vault-storage/immich";
  };

  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.${tailnetDomain}";      # Replace with your Tailscale IP or domain
    home = "/mnt/vault-storage/nextcloud";

    # Automatic local database & Redis caching setup
    database.createLocally = true;
    configureRedis = true;

    maxUploadSize = "10G";

    config = {
      adminuser = "admin";
      adminpassFile = "/var/lib/nextcloud/admin-pass";
      dbtype = "pgsql";
    };

    settings = {
      trusted_domains = [ "nextcloud.${tailnetDomain}" ];
    };
  };

  # Open Firewall ports for Nextcloud (HTTP/HTTPS) and Immich
  networking.firewall.allowedTCPPorts = [ 80 443 2283 ];
}
