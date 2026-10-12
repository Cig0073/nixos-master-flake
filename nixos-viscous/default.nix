{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../modules/profiles/plasma-bigscreen.nix
  ];

  # Boot straight into the Bigscreen session
  services.displayManager.defaultSession = "plasma-bigscreen-wayland";

  # ── NVIDIA hybrid graphics (legacy 580 driver + Intel iGPU) ──────────────
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open               = false;
    nvidiaSettings     = true;
    package            = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    prime = {
      sync.enable  = true;
      intelBusId   = "PCI:0@0:2:0";
      nvidiaBusId  = "PCI:1@0:0:0";
    };
  };

  environment.sessionVariables = {
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    # Force GTK4 apps to use the Cairo renderer (avoids 3D-compositor dependency)
    GSK_RENDERER          = "cairo";
  };

  # ── Fix missing KDE Connect dependency in plasma-bigscreen ────────────────
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

  system.stateVersion = "26.05";
}
