{config, libs, pkgs, inputs, ...}:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.millennium.overlays.default ];
  programs.steam = {
    enable = true;
    package = pkgs.millennium-steam;
  };
  environment.systemPackages = with pkgs; [
	ludusavi
	hydralauncher
	gnutar
	_7zz
	umu-launcher
	wineWow64Packages.stable
	winetricks
	moonlight-qt
  ];
}
