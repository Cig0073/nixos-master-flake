# nixos-viscous/disko.nix
# Declarative disk layout for nixos-viscous (Intel/NVIDIA hybrid laptop).
#
# enableConfig = false — fileSystems managed by hardware-configuration.nix.
# Fresh install:
#   nix run github:nix-community/disko#disko-install -- \
#     --flake .#nixos-viscous --disk main /dev/nvme0n1
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
            extraArgs    = [ "-n" "NIXBOOT" ];
            mountpoint   = "/boot";
            mountOptions = [ "fmask=0022" "dmask=0022" ];
          };
        };
        root = {
          size    = "100%";
          content = {
            type      = "btrfs";
            extraArgs = [ "-L" "NIXROOT" ];
            subvolumes = {
              "@" = {
                mountpoint   = "/";
                mountOptions = [ "compress=zstd" ];
              };
              "@home" = {
                mountpoint   = "/home";
                mountOptions = [ "compress=zstd" ];
              };
              "@nix" = {
                mountpoint   = "/nix";
                mountOptions = [ "compress=zstd" ];
              };
            };
          };
        };
      };
    };
  };
}
