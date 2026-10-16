# nixbook-air/disko.nix
# Declarative disk layout for nixbook-air (Intel laptop with LUKS full-disk encryption).
#
# enableConfig = false — fileSystems managed by hardware-configuration.nix.
# Fresh install:
#   nix run github:nix-community/disko#disko-install -- \
#     --flake .#nixbook-air --disk main /dev/nvme0n1
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
        luks = {
          size    = "100%";
          content = {
            type    = "luks";
            name    = "nixcrypt";
            # Strong defaults; on re-install adjust as needed
            settings.allowDiscards = true;
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
                "@log" = {
                  mountpoint   = "/var/log";
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
  };
}
