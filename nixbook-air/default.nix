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

  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver intel-vaapi-driver ];
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver intel-vaapi-driver ];

  system.stateVersion = "26.05"; # Did you read the comment?

}

