{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "26.11";
}
