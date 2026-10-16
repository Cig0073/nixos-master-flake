# nixos-vault/disko-storage.nix
# Declarative layout for vault's two extra data drives.
#
# Drive topology (confirmed from lsblk):
#   sda        500G  ─ vault-storage mirror leg A
#   └─ sda1    500G    Btrfs RAID-1 mirror, label "vault-storage"
#
#   sdb        976G  ─ hybrid drive
#   ├─ sdb1    500G    Btrfs RAID-1 mirror, label "vault-storage" (mirror leg B)
#   └─ sdb2    488G    Btrfs single-volume, label "vault-nonmirrored"
#
# enableConfig = false — fileSystems are declared in filesystems.nix.
# On a fresh install, run disko-install and then:
#   mkfs.btrfs -m raid1 -d raid1 -L vault-storage /dev/sda1 /dev/sdb1
#   mkfs.btrfs -L vault-nonmirrored /dev/sdb2
{ ... }:
{
  disko.enableConfig = false;

  disko.devices.disk = {
    # Mirror leg A: 500 GB drive — entire disk is the Btrfs mirror member
    vault-a = {
      device = "/dev/sda";
      type   = "disk";
      content = {
        type = "gpt";
        partitions.storage-a = {
          size    = "100%";
          content = {
            type         = "filesystem";
            format       = "btrfs";
            # Provisioned as half of a RAID-1 mirror with vault-b.storage-b
            # mkfs.btrfs -m raid1 -d raid1 -L vault-storage /dev/sda1 /dev/sdb1
            mountpoint   = "/mnt/vault-storage";
            mountOptions = [ "compress=zstd" "noatime" ];
          };
        };
      };
    };

    # Hybrid drive: sdb holds mirror leg B (sdb1) + standalone pool (sdb2)
    vault-b = {
      device = "/dev/sdb";
      type   = "disk";
      content = {
        type = "gpt";
        partitions = {
          storage-b = {
            size    = "500G";
            content = {
              type         = "filesystem";
              format       = "btrfs";
              # Mirror leg B — same Btrfs UUID as sda1 after mkfs.btrfs -m raid1
              mountpoint   = null;   # mounted via sda1; no separate mountpoint
              mountOptions = [];
            };
          };
          nonmirrored = {
            size    = "100%";
            content = {
              type         = "filesystem";
              format       = "btrfs";
              mountpoint   = "/mnt/vault-nonmirrored";
              mountOptions = [ "compress=zstd" "noatime" ];
            };
          };
        };
      };
    };
  };
}
