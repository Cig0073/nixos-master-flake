{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Handheld daemon (TDP/fan control for ROG Ally)
  services.handheld-daemon = {
    enable = true;
    user   = "cig0073";
  };

  # ASUS system daemon (keyboard backlight, battery charge limit, etc.)
  services.asusd.enable = true;

  # rtkit already enabled in base-config.nix

  system.stateVersion = "26.05";
}
