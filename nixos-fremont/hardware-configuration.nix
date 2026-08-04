{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ 
    "nvme" "uas" "usb_storage" "sd_mod" "ahci" "xhci_pci" "ehci_pci" "thunderbolt"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.enableAllHardware = true;
  #services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  hardware.graphics = {
      enable = true;
      enable32Bit = true; 
      extraPackages = with pkgs; [ libva-vdpau-driver libvdpau-va-gl ];
    };

  #For main pc ethernet.
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
