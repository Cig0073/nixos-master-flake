{ config, ... }:
{
  boot.loader = {
    systemd-boot.enable   = false;
    efi.canTouchEfiVariables = true;

    limine = {
      enable        = true;
      efiSupport    = true;
      maxGenerations = 10;
      style = {
        interface.branding =
          "Welcome to " + config.networking.hostName + ". May you become a son of liberty!";
        wallpapers       = [ ./dark-messiah-hl.jpg ];
        graphicalTerminal.background = "FF000000";
      };
    };
  };
}
