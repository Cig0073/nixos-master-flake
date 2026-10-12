# profiles/plasma-bigscreen.nix
# KDE Plasma 6 + Bigscreen session on Wayland via SDDM.
# Shared display stack used by:
#   - nixos-fremont (Jovian HTPC; boots into Steam, switches to Bigscreen desktop)
#   - nixos-viscous (Laptop; boots directly into Bigscreen session)
{ pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;
  };

  services.displayManager.sessionPackages = [
    pkgs.kdePackages.plasma-bigscreen
  ];

  xdg.portal.configPackages = [
    pkgs.kdePackages.plasma-bigscreen
  ];
}
