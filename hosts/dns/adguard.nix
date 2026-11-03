# hosts/dns/adguard.nix — DNS policy, identical on every node
#
# The web UI is read-only in practice (mutableSettings = false): change
# things here, commit, and every node converges on its next upgrade slot.
{
  services.adguardhome.settings = {
    dns = {
      upstream_dns = [
        "tls://dns.quad9.net"
        "tls://1dot1dot1dot1.cloudflare-dns.com"
        # "[/k8s.home.arpa/]192.168.88.240" # k8s_gateway, once deployed
      ];
      bootstrap_dns = [ "9.9.9.9" "1.1.1.1" ];
      upstream_mode = "load_balance";
      cache_optimistic = true; # keep answering from cache if upstreams are down
    };

    filtering = {
      protection_enabled = true;
      filtering_enabled = true;
      rewrites = [
        # { domain = "nas.home.arpa"; answer = "192.168.88.20"; enabled = true; }
      ];
    };

    filters = [
      {
        id = 1;
        enabled = true;
        name = "AdGuard DNS filter";
        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
      }
    ];

    user_rules = [ ];
  };
}
