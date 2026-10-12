# steamos-system-modifications.nix
# SteamOS-compatible system tweaks: power button, Wake-on-LAN/Bluetooth.
{ pkgs, ... }:
{
  # Let steampowerbuttond handle the power button instead of logind
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # ── Wake-on-LAN (all ethernet interfaces) ─────────────────────────────────
  systemd.network.links."10-wake-on-lan" = {
    matchConfig.OriginalName = "e*";
    linkConfig.WakeOnLan     = "magic";
  };

  # Force WoL defaults for NetworkManager-generated profiles (helps with tmpfs)
  networking.networkmanager.settings.connection."802-3-ethernet.wake-on-lan" = 1;

  # ── Wake-on-Bluetooth ─────────────────────────────────────────────────────
  services.udev.extraRules = ''
    ACTION=="add|bind", SUBSYSTEM=="bluetooth", ATTR{power/wakeup}="enabled"
    ACTION=="add|bind", SUBSYSTEM=="usb", DRIVERS=="btusb", ATTR{power/wakeup}="enabled"
    ACTION=="add|bind", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="e0", ATTR{bInterfaceSubClass}=="01", ATTR{bInterfaceProtocol}=="01", ATTR{power/wakeup}="enabled"
  '';

  # ── Prevent USB wakeup on shutdown (avoid instant-reboot after poweroff) ──
  systemd.services.disable-usb-wakeup-on-poweroff = {
    description = "Disable USB wakeup before poweroff to prevent instant reboot";
    wantedBy    = [ "final.target" ];
    before      = [ "final.target" ];
    serviceConfig = {
      Type      = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'for dev in /sys/bus/usb/devices/*/power/wakeup; do echo disabled > \"$dev\" 2>/dev/null || true; done'";
    };
  };
}
