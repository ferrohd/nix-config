# hosts/dns/nodes.nix — single source of truth for the DNS fleet
#
# Every node gets the exact same configuration (hosts/dns/default.nix);
# only the facts below differ. Adding a node:
#   1. add an entry to `nodes`
#   2. put its hardware-configuration.nix in hosts/dns/<name>/
#   3. install it once (nixos-anywhere / just deploy); auto-upgrade takes over
#   4. just mikrotik-dns   (re-renders and imports the router side)
{
  site = {
    anycastAddress = "10.53.53.53";

    lan = {
      prefixLength = 24;
      gateway = "192.168.88.1";
    };

    bgp = {
      nodeAS = 65053;
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
      address = "192.168.88.11";
      stateVersion = "26.05"; # set once at install time, never bump
    };

    # dns2 = {
    #   system = "aarch64-linux";
    #   interface = "end0";
    #   address = "192.168.88.12";
    #   stateVersion = "26.05";
    # };
  };
}
