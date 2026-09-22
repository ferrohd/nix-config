# hosts/dns/nodes.nix — single source of truth for the DNS fleet
#
# Every node gets the exact same configuration (hosts/dns/default.nix);
# only the facts below differ. Nodes take their LAN address from DHCP, so
# the router peers with the whole subnet (one dynamic BGP listener) rather
# than with each node by address. Adding a node:
#   1. add an entry to `nodes`
#   2. put its hardware-configuration.nix in hosts/dns/<name>/
#   3. install it once (nixos-anywhere / just deploy); auto-upgrade takes over
# The router side never changes — `just mikrotik-dns` is one-time setup.
{
  site = {
    anycastAddress = "10.53.53.53";

    # Subnet the nodes live on. Only used to render the router's dynamic
    # BGP listener (lib/mikrotik-dns.nix); the nodes themselves use DHCP.
    lan.subnet = "192.168.88.0/24";

    bgp = {
      nodeAS = 65053;
      # The nodes dial out to the router, and BIRD's config is static in the
      # Nix store, so this can't be learned from the DHCP lease.
      routerAddress = "192.168.88.1";
      routerAS = 65000;
    };

    # Only used to render the RouterOS script (lib/mikrotik-dns.nix)
    mikrotik.bgpInstance = "home";
  };

  nodes = {
    dns1 = {
      system = "x86_64-linux";
      interface = "enp1s0";
      stateVersion = "26.05"; # set once at install time, never bump
    };

    dns2 = {
      system = "x86_64-linux";
      interface = "enp1s0"; # guess — confirm with `ip link` at install time
      stateVersion = "26.05";
    };
  };
}
