{ ... }:

{
  boot = {
  	loader.systemd-boot.enable = false;
  	loader.efi.canTouchEfiVariables = true;
    loader.limine = {
      enable = true;
	    style.interface.branding = "NixPal";
	    style.wallpapers = [ ./dark-messiah-hl.jpg ];
	    style.graphicalTerminal.background = "00000000";
      efiSupport = true;
      maxGenerations = 10;
    };
  };
}
