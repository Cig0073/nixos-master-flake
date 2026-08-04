{ pkgs, config, lib, ...}:

{
  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extest.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
  	#enableWsi = true; not yet in the repos
  	#capSysNice = true;
  };

  hardware.steam-hardware.enable = true;

 # programs.gamescope.enable = true;
 # programs.gamescope.capSysNice = true;

  services.sunshine = {
  	enable = true;
  	openFirewall = true;
  	capSysAdmin = true;
  	autoStart = true;
  };

  services.displayManager = {
  	defaultSession = "steam";
  	autoLogin.user = "cig0073";
  	autoLogin.enable = true;
  };

  environment.systemPackages = with pkgs; [
	kdePackages.plasma-keyboard
  	lutris
  	ludusavi
  	mangohud
  ];
}
