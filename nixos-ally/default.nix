# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.handheld-daemon.user = "cig0073";
  services.handheld-daemon.enable = true;
  services.asusd.enable = true;

  security.rtkit.enable = true;

  system.stateVersion = "26.05"; # Did you read the comment?

}

