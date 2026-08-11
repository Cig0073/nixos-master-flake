{ config, ... }:

{
  boot = {
  	loader.systemd-boot.enable = false;
  	loader.efi.canTouchEfiVariables = true;
    loader.limine = {
      enable = true;
	    style.interface.branding = "Welcome to " + config.networking.hostName + ". May you become a son of liberty!";
	    style.wallpapers = [ ./dark-messiah-hl.jpg ];
	    style.graphicalTerminal.background = "FF000000";
      efiSupport = true;
      maxGenerations = 10;
    };
  };
}
