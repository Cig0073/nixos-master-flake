#
# copy of jovian.nix -- Gaming
#
{ pkgs, ...}:

{
  system.activationScripts = {
    print-jovian = {
      text = builtins.trace "building the jovian configuration..." "";
    };
  };

  plymouth = {
    enable = true;
    theme = "motion";
    themePackages = with pkgs; [
      # By default we would install all themes
      (adi1090x-plymouth-themes.override {
        selected_themes = [ "motion" ];
      })
    ];
  };
  boot = {
    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };

  environment.systemPackages = with pkgs; [    
    mangohud
  	kdePackages.plasma-bigscreen
    kdePackages.plasma-keyboard
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

  hardware.steam-hardware.enable = true;

  jovian.decky-loader.enable = true;
  jovian.decky-loader.user = "cig0073";
  #jovian.devices.steamdeck.autoUpdate = true;
  jovian.steamos.useSteamOSConfig = true;
  #jovian.devices.steamdeck.enable = true;
  #jovian.devices.steamdeck.enableGyroDsuService = true;
  
  services.orca.enable = true;

}
