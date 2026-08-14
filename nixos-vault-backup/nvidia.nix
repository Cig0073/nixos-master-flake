{config, lib, pkgs, ...}:

{

  nixpkgs.config.allowUnfree = true;

  hardware.graphics.enable = true;  
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
  };

  environment.sessionVariables = {
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    # Force all modern GTK4 apps to render cleanly without a 3D compositor
    GSK_RENDERER = "cairo";
  };
}
