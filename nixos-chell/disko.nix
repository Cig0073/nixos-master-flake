# nixos-chell/disko.nix
# Declarative disk layout — shared by nixos-chell, nixos-vault, nixos-fremont
# (all three boot from the same physical NVMe, GPT-partitioned).
#
# enableConfig = false because this machine was not originally provisioned with
# disko; fileSystems are already declared in hardware-configuration.nix.
# On a FRESH install, set enableConfig = true and run:
#   nix run github:nix-community/disko#disko-install -- \
#     --flake .#nixos-chell --disk main /dev/nvme0n1
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
            # Subvolume names match the ones created at install time
            subvolumes = {
              "@root" = {
                mountpoint   = "/";
                mountOptions = [ "compress=zstd" ];
              };
              "@nixos_nix" = {
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
