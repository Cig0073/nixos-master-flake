{ pkgs, ...}:

{

  environment.sessionVariables = {
    PROTON_ENABLE_WAYLAND = "1";
    PROTON_DXVL_LOWLATENCY = "1";
    PROTON_FSR4_UPGRADE = "1";
    PROTON_MLFG_UPGRADE = "1";
    MANGOHUD = "1";
  };
  
  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extest.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin proton-cachyos ];
  };

  programs.gamescope = {
    enable = true;
  	#enableWsi = true; not yet in the repos
  	capSysNice = true;
  };

  hardware.steam-hardware.enable = true;

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };

      # Warning: GPU optimisations have the potential to damage hardware
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
      };
    };
  };

  environment.systemPackages = with pkgs; [
  	lutris
  	mangohud
  ];
}
