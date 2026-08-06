# /etc/nixos/configuration.nix

{ pkgs, ... }:

{

  # Prevent the system from shutting down when the power button is pressed
  # This allows steampowerbuttond to handle the event instead
  services.logind.settings.Login.HandlePowerKey = "ignore";

# Global Wake-on-LAN for all ethernet interfaces (e*)
  systemd.network.links."10-wake-on-lan" = {
    matchConfig.OriginalName = "e*";
    linkConfig.WakeOnLan = "magic";
  };

  # If you use NetworkManager, force WoL defaults globally across generated profiles (helps with tmpfs):

  networking.networkmanager.settings = {
      connection = {
        "802-3-ethernet.wake-on-lan" = 1;
      };
    };
  # Wake-on-Bluetooth for all integrated and USB adapters
  services.udev.extraRules = ''
    ACTION=="add|bind", SUBSYSTEM=="bluetooth", ATTR{power/wakeup}="enabled"
    ACTION=="add|bind", SUBSYSTEM=="usb", DRIVERS=="btusb", ATTR{power/wakeup}="enabled"
    ACTION=="add|bind", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="e0", ATTR{bInterfaceSubClass}=="01", ATTR{bInterfaceProtocol}=="01", ATTR{power/wakeup}="enabled"
  '';
  # Disable USB wakeup right before poweroff/shutdown (leaves suspend untouched)
  systemd.services.disable-usb-wakeup-on-poweroff = {
    description = "Disable USB wakeup before poweroff to prevent instant reboot";
    wantedBy = [ "final.target" ];
    before = [ "final.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'for dev in /sys/bus/usb/devices/*/power/wakeup; do echo disabled > \"$dev\" 2>/dev/null || true; done'";
    };
  };
}
