# nixos-fremont/disko.nix
# Fremont shares the same physical NVMe and disk partitioning as nixos-chell.
{ ... }:
{
  imports = [ ../nixos-chell/disko.nix ];
}
