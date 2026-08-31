{
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      server_names = [ "cloudflare" "quad9-dnscrypt-ip4-filter-pri" ];
      listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];
    };
  };
  networking.nameservers = [ "127.0.0.1" "::1" ];
  networking.networkmanager.dns = "none";

  services.zapret = {
    enable = true;
    params = [
      "--dpi-desync=fakedsplit" "--dpi-desync-fooling=badseq" "--dpi-desync-badseq-increment=0" "--dpi-desync-split-pos=1"
    ];
  };
}
