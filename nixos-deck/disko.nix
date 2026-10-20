# nixos-deck/disko.nix
# Declarative disk layout for Steam Deck (LCD & OLED internal NVMe).
#
# Single Btrfs storage pool shared across Steam games, emulators, ROMs, and desktop.
# enableConfig = false preserves existing partitions during flake updates.
# On a FRESH installation from CachyOS:
#   Set enableConfig = true (or run disko-install) to format and install:
#   nix run github:nix-community/disko#disko-install -- \
#     --flake .#nixos-deck --disk main /dev/nvme0n1
{ ... }:
{
  disko.enableConfig = false;

  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type   = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "512M";
          content = {
            type         = "filesystem";
            format       = "vfat";
            mountpoint   = "/boot";
            mountOptions = [ "fmask=0022" "dmask=0022" ];
          };
        };
        root = {
          size    = "100%";
          content = {
            type      = "btrfs";
            subvolumes = {
              "@root" = {
                mountpoint   = "/";
                mountOptions = [ "compress=zstd" ];
              };
              "@nix" = {
                mountpoint   = "/nix";
                mountOptions = [ "compress=zstd" ];
              };
              "@home" = {
                mountpoint   = "/home";
                mountOptions = [ "compress=zstd" ];
              };
            };
          };
        };
      };
    };
  };
}
