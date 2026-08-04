{ ... }:

{
  # Root filesystem mounted directly from a persistent Btrfs subvolume
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1668713f-a2dd-4f83-8d98-5ab29edfc107";
    fsType = "btrfs";
    options = [ "subvol=@root" "compress=zstd" ];
  };

  # Dedicated Nix store subvolume
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/1668713f-a2dd-4f83-8d98-5ab29edfc107";
    fsType = "btrfs";
    options = [ "subvol=@nixos_nix" "compress=zstd" ];
  };

  # User Home directories
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/1668713f-a2dd-4f83-8d98-5ab29edfc107";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" ];
  };

  # Shared EFI boot partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/16C5-9FBB";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };
  # =========================================================================
  # 2. HIGH-PERFORMANCE ZRAM SWAP
  # =========================================================================
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
    priority = 5;
  };
}
