{config, pkgs, ...}:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

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

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.displayManager = {
    defaultSession = "plasma-bigscreen-wayland";
    sessionPackages = [ pkgs.kdePackages.plasma-bigscreen ];
  };
  
  xdg.portal.configPackages = [ pkgs.kdePackages.plasma-bigscreen ];

  # Apply the overlay fix to patch in the missing KDE Connect dependency
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages // {
        plasma-bigscreen = prev.kdePackages.plasma-bigscreen.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ prev.kdePackages.kdeconnect-kde ];
          preFixup = (old.preFixup or "") + ''
            wrapQtApp $out/bin/plasma-bigscreen-wayland \
              --prefix QML2_IMPORT_PATH : "${prev.kdePackages.kdeconnect-kde}/lib/qt-6/qml"
          '';
        });
      };
    })
  ];
}

