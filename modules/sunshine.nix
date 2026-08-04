
{ ... }:
{
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
}
