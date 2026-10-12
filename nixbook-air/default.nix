{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Intel integrated graphics VA-API acceleration
  hardware.graphics = {
    extraPackages    = with pkgs; [ intel-media-driver intel-vaapi-driver ];
    extraPackages32  = with pkgs.pkgsi686Linux; [ intel-media-driver intel-vaapi-driver ];
  };

  system.stateVersion = "26.05";
}
