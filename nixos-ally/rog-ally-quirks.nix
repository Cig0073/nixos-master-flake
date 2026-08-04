{ ... }:

{
  services.handheld-daemon.user = "cig0073";
  services.handheld-daemon.enable = true;
  services.asusd.enable = true;

  security.rtkit.enable = true;
}
