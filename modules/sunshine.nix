{ config, ... }:
{
  services.sunshine = {
    enable      = true;
    openFirewall = true;
    capSysAdmin = true;
    autoStart   = true;
    settings = {
      upnp                 = "enabled";
      csrf_allowed_origins = config.nixcore.sunshineOrigin;
      origin_pin_allowed   = "lan";
      origin_web_ui_allowed = "lan";
    };
  };

  services.sunshine-virt-display.enable = true;
}
