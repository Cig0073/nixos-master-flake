{config, lib, pkgs, inputs, ...}:

{

  imports = [
      inputs.arion.nixosModules.arion
  ];

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    daemon.settings = {
   	  data-root = "/docker";
  	  userland-proxy = false;
	};
  };

  virtualisation.arion = {
    # Set this to "docker" or "podman-socket" depending on your container engine
    backend = "docker"; 

    projects.lancommander = {
      settings = {
        services.lancommander = {
          service = {
            image = "lancommander/lancommander:latest";
            container_name = "lancommander";
            
            environment = {
              PUID = "1000";
              PGID = "1000";
              TZ = "Etc/UTC";
              # Uncomment these inside the attribute set if needed:
              STEAMCMD = "1";
              # WINE = "1";
            };

            volumes = [
              "/var/lib/lancommander/app/data:/app/Data"
            ];

            ports = [
              "1337:1337/tcp"   # Web interface
              "35891:35891/udp" # Beacon broadcast
              "213:213/udp"     # IPX relay
            ];

            restart = "unless-stopped";
          };
        };
      };
    };
  };
  
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 1337 ];
  users.users.cig0073.extraGroups = [ "docker" ];
	
}
