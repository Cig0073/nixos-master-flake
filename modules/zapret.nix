# zapret.nix — DPI circumvention (shared base config)
{ ... }:
{
  services.zapret = {
    enable = true;
    params = [
      "--dpi-desync=fakeddisorder"
      "--dpi-desync-fooling=ts"
      "--dpi-desync-split-pos=1"
    ];
  };
}
