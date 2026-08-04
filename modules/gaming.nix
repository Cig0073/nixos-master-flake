{ pkgs, ...}:

{
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

  environment.systemPackages = with pkgs; [
  	lutris
  	ludusavi
  	mangohud
  ];
}
