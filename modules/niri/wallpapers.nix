
# wallpapers.nix
{ pkgs, inputs, ... }:

let
  # Direct references to the flake inputs
  nixosArtwork = inputs.nixos-artwork;
  catppuccinWallpapers = inputs.catppuccin-wallpapers;

  wallpaperStore = pkgs.runCommand "dms-wallpaper-categories" {} ''
    # Create clean category folders
    mkdir -p $out/4k $out/scrolling $out/gifs $out/16-10 $out/4-3-retro

    # --- 1. 4K Standard Widescreen (16:9) ---
    cp ${nixosArtwork}/wallpapers/nix-wallpaper-stripes-logo.png $out/4k/nixos-stripes-4k.png 2>/dev/null || true
    cp ${nixosArtwork}/wallpapers/nix-wallpaper-mosaic-blue.png $out/4k/nixos-mosaic-4k.png 2>/dev/null || true
    if [ -d "${catppuccinWallpapers}/src" ]; then
      find ${catppuccinWallpapers}/src -type f \( -name "*.png" -o -name "*.jpg" \) -exec cp {} $out/4k/ \; 2>/dev/null || true
    fi

    # --- 2. Scrolling / Ultrawide Panoramas (32:9) ---
    cp ${nixosArtwork}/wallpapers/nix-wallpaper-dracula.png $out/scrolling/nixos-dracula-panorama.png 2>/dev/null || true
    cp ${nixosArtwork}/wallpapers/nix-wallpaper-nineish-dark.png $out/scrolling/nixos-nineish-wide.png 2>/dev/null || true

    # --- 3. Animated GIF Wallpapers ---
    find ${nixosArtwork} ${catppuccinWallpapers} -type f -name "*.gif" -exec cp {} $out/gifs/ \; 2>/dev/null || true

    # --- 4. 16:10 Aspect Ratio ---
    cp ${nixosArtwork}/wallpapers/nix-wallpaper-simple-dark-gray.png $out/16-10/nixos-simple-dark-16-10.png 2>/dev/null || true
    cp ${nixosArtwork}/wallpapers/nix-wallpaper-simple-blue.png $out/16-10/nixos-simple-blue-16-10.png 2>/dev/null || true
    find ${catppuccinWallpapers} -type f \( -name "*16-10*" -o -name "*16x10*" -o -name "*deck*" \) -exec cp {} $out/16-10/ \; 2>/dev/null || true
  '';
in
{
  # Dank Material Shell folder path (/etc/wallpapers)
  environment.etc."wallpapers".source = wallpaperStore;

  # XDG Standard Backgrounds Directory Layout (/run/current-system/sw/share/backgrounds)
  environment.systemPackages = [
    (pkgs.runCommand "xdg-backgrounds-layout" {} ''
      mkdir -p $out/share/backgrounds
      ln -s ${wallpaperStore}/* $out/share/backgrounds/
    '')
  ];
}
