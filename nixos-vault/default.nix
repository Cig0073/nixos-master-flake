{ pkgs, ... }:

let
  tailnetDomain = "nixos.tail8a17d2.ts.net";
in
{
  imports = [ ./filesystems.nix ];

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
  ];

  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";  
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    openFirewall = true;
    mediaLocation = "/mnt/vault-storage/immich";
  };

  services.nextcloud = {
    enable = true;
    hostName = tailnetDomain;      # Replace with your Tailscale IP or domain
    home = "/mnt/vault-storage/nextcloud";
    database.createLocally = true;
    configureRedis = true;

    maxUploadSize = "10G";

    config = {
      adminuser = "admin";
      adminpassFile = "/var/lib/nextcloud/admin-pass";
      dbtype = "pgsql";
    };

    settings = {
      overwriteprotocol = "https";
      trusted_domains = [
        "127.0.0.1"
        "localhost"
        tailnetDomain
      ];
    };
  };

  services.nginx.virtualHosts."${tailnetDomain}" = {
    listen = [{ addr = "127.0.0.1"; port = 8085; }];
  };
  
  services.caddy = {
    enable = true;
    virtualHosts."${tailnetDomain}" = {
      extraConfig = ''
        tls {
          get_certificate tailscale
        }
        reverse_proxy http://127.0.0.1:8085
      '';
    };
  };
  users.users.caddy.extraGroups = [ "tailscale" ];

  # Open Firewall ports for Nextcloud (HTTP/HTTPS) and Immich
  networking.firewall.allowedTCPPorts = [ 80 443 2283 ];
}
