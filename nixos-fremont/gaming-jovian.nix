#
# copy of jovian.nix -- Gaming
#
{ config, pkgs, lib, inputs, ...}:

{
/*
  imports = [
  	./steam-switch.nix
  ];
*/
  system.activationScripts = {
    print-jovian = {
      text = builtins.trace "building the jovian configuration..." "";
    };
  };

  # Create a custom session definition that drops to SDDM
  environment.systemPackages = with pkgs; [    
    lutris
    ludusavi
    mangohud
    #proton-ge-bin
  ];  
  
  jovian.steam = {
  	enable = true;
  	autoStart = true;
  	desktopSession = "plasma-bigscreen-wayland";
  	user = "cig0073";
    environment = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/run/current-system/sw/share/steam/compatibilitytools.d";
    };
  };  

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extest.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin proton-cachyos ];
    #gamescopeSession.enable = true;
  };

  hardware.steam-hardware.enable = true;

  services.sunshine = {
  	enable = true;
  	openFirewall = true;
  	capSysAdmin = true;
  	autoStart = true;
  	settings = {
  	  upnp = "enabled";
  	  csrf_allowed_origins = "https://192.168.0.12";
  	  origin_pin_allowed = "lan";
  	  origin_web_ui_allowed = "lan";
  	};
  };

  services.sunshine-virt-display.enable = true;
  
  jovian.decky-loader.enable = true;
  jovian.decky-loader.user = "cig0073";
  #jovian.devices.steamdeck.autoUpdate = true;
  jovian.steamos.useSteamOSConfig = true;
  #jovian.devices.steamdeck.enable = true;
  #jovian.devices.steamdeck.enableGyroDsuService = true;
  
  services.orca.enable = true;

}
