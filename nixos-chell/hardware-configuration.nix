{ config, ... }:

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

  boot.initrd.availableKernelModules = [ 
    "nvme" "uas" "usb_storage" "sd_mod" "ahci" "xhci_pci" "ehci_pci" "thunderbolt"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];

  hardware.enableRedistributableFirmware = true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.enableAllHardware = true;

  # 1. Keep the specific driver compiled and available in the system closure
  boot.extraModulePackages = [ 
    config.boot.kernelPackages.r8168 
  ];

  # 2. Dynamically swap drivers ONLY on your specific MSI motherboard
  boot.extraModprobeConfig = ''
    # If the system detects the Realtek chip, run a shell check first.
    # If the motherboard string matches your MSI B460M-A PRO, force r8168 to load and prevent r8169.
    install r8169 /bin/sh -c 'if [ "$(cat /sys/class/dmi/id/board_name 2>/dev/null)" = "B460M-A PRO (MS-7C88)" ]; then /run/current-system/sw/bin/modprobe r8168; else /run/current-system/sw/bin/modprobe --ignore-install r8169; fi'
  '';
}
