{ pkgs, ... }:

let
  tailnetDomain = "nixos.tail8a17d2.ts.net";
in
{
  imports = [ ./filesystems.nix ];

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr
  ];
  # Enable Ollama with ROCm acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    
    # Optional: Automatically pull the light model on startup
    loadModels = [ "qwen2.5:3b" ];

    # Optional: If you use a consumer GPU (like RX 6000/7000 or Steam Deck/ROG Ally iGPU) 
    # that ROCm doesn't recognize out-of-the-box, uncomment the override line below:
    # rocmOverrideGfx = "11.0.0"; # e.g. "10.3.0" for RDNA2 or "11.0.0" for RDNA3
  };

  # Enable Docker
  virtualisation.docker.enable = true; 

  # Make sure the user is allowed to access GPU hardware render nodes
  users.users.cig0073.extraGroups = [ "docker" "render" "video" ];

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
