{
  # Enable Btrfs filesystem utilities
  boot.supportedFilesystems = [ "btrfs" ];

  # Mirrored 500GB Storage Pool
  fileSystems."/mnt/vault-storage" = {
    device = "/dev/disk/by-label/vault-storage";
    fsType = "btrfs";
    options = [ 
      "compress=zstd" # Enable transparent ZSTD compression
      "noatime"       # Performance optimization (reduces disk writes)
      "X-mount.mkdir" # Automatically creates mount directory if missing
    ];
  };

  # Non-Mirrored ~500GB Storage Pool
  fileSystems."/mnt/vault-nonmirrored" = {
    device = "/dev/disk/by-label/vault-nonmirrored";
    fsType = "btrfs";
    options = [ 
      "compress=zstd"
      "noatime"
      "X-mount.mkdir"
    ];
  };
}
