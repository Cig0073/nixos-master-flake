{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./filesystems.nix
    ./disko.nix
    ../modules/profiles/plasma-bigscreen.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # fremont is an HTPC — enable HiDPI scaling for the display manager
  services.displayManager.sddm.enableHidpi = true;

  # Keyboard layout (for the occasional physical keyboard)
  services.xserver.xkb = {
    layout  = "us";
    variant = "";
  };

  environment.systemPackages = with pkgs; [
    kdePackages.plasma-bigscreen
    kdePackages.plasma-keyboard
    kdePackages.partitionmanager
  ];

  system.stateVersion = "26.05";
}
