{ config, lib, pkgs, ... }:

let
  cfg = config.myconfig.anycastDns;
  inherit (lib) mkOption types;
  birdc = lib.getExe' config.services.bird.package "birdc";
in
{
  # ── Anycast DNS node (opt-in via myconfig.anycastDns.enable) ────────────
  # AdGuard Home answers on a shared anycast /32 that every node announces
  # to the router over BGP. A health loop withdraws the announcement as soon
  # as the local AdGuard stops answering, so the router steers clients to
  # the remaining nodes. This module is the mechanism only; DNS policy
  # (upstreams, filters, rewrites) lives in hosts/dns/adguard.nix.
  options.myconfig.anycastDns = {
    enable = lib.mkEnableOption "anycast DNS node (AdGuard Home + BGP)";

    # The node's LAN address comes from DHCP: nothing here or on the router
    # is keyed on it, so nodes are interchangeable and the router peers with
    # the subnet instead of with each machine.
    lan.interface = mkOption { type = types.str; example = "enp1s0"; };

    anycastAddress = mkOption { type = types.str; };

    bgp = {
      nodeAS = mkOption { type = types.ints.unsigned; };
      routerAddress = mkOption { type = types.str; };
      routerAS = mkOption { type = types.ints.unsigned; };
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Networking: networkd, no NetworkManager ─────────────────────────
    networking = {
      networkmanager.enable = lib.mkForce false;
      useNetworkd = true;
      useDHCP = false; # legacy dhcpcd; networkd does DHCP per-link below
      firewall = {
        allowedTCPPorts = [ 53 179 ];
        allowedUDPPorts = [ 53 ];
      };
    };

    # AdGuard binds the anycast address, which networkd may not have put on
    # anycast0 yet (it is RequiredForOnline = "no"). Standard anycast
    # practice, and it removes the startup race.
    boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;

    systemd.network = {
      enable = true;
      netdevs."10-anycast".netdevConfig = { Kind = "dummy"; Name = "anycast0"; };
      networks = {
        "10-lan" = {
          matchConfig.Name = cfg.lan.interface;
          networkConfig.DHCP = "ipv4";
          # The node resolves through its own AdGuard; the public fallback
          # keeps auto-upgrade working while AdGuard is down. Ignore whatever
          # the lease says so the router can't point us at ourselves.
          dhcpV4Config = { UseDNS = false; UseDomains = false; };
          dns = [ "127.0.0.1" "9.9.9.9" ];
          linkConfig.RequiredForOnline = "routable";
        };
        "10-anycast" = {
          matchConfig.Name = "anycast0";
          address = [ "${cfg.anycastAddress}/32" ];
          linkConfig.RequiredForOnline = "no";
        };
      };
    };

    # ── AdGuard Home ─────────────────────────────────────────────────────
    services.adguardhome = {
      enable = true;
      mutableSettings = false; # git is the only source of truth
      host = "127.0.0.1"; # no UI users configured: reach it via `ssh -L 3000:localhost:3000`
      port = 3000;
      settings = {
        dns = {
          # Explicit binds, not 0.0.0.0: systemd-resolved (hosts/common)
          # already holds 127.0.0.53:53. The DHCP-assigned LAN address is
          # deliberately not bound — clients reach the service on the
          # anycast address; debug with `dig @${cfg.anycastAddress}`.
          bind_hosts = [ "127.0.0.1" cfg.anycastAddress ];
          port = 53;
        };
        # Probe target for the health loop below
        filtering.rewrites = [
          { domain = "health.home.arpa"; answer = "127.0.0.1"; enabled = true; }
        ];
      };
    };

    systemd.services.adguardhome = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };

    # `router id from` fails to start bird if the DHCP lease hasn't landed.
    systemd.services.bird = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };

    # ── BGP announcement ─────────────────────────────────────────────────
    services.bird = {
      enable = true;
      config = ''
        # Derived from the DHCP lease, so it differs per node without any
        # per-node config. Picked once at startup: bird waits for the link.
        router id from "${cfg.lan.interface}";

        protocol device { }

        # Starts disabled; dns-anycast-health enables it once AdGuard answers
        protocol static anycast_dns {
          disabled;
          ipv4;
          route ${cfg.anycastAddress}/32 via "anycast0";
        }

        # No local address: bird uses the source address of the route to the
        # neighbor, whatever DHCP handed us. The router listens for dynamic
        # peers from this subnet, so it needs no matching entry per node.
        protocol bgp uplink {
          local as ${toString cfg.bgp.nodeAS};
          neighbor ${cfg.bgp.routerAddress} as ${toString cfg.bgp.routerAS};
          hold time 9;
          keepalive time 3;
          ipv4 {
            import none;
            export where net = ${cfg.anycastAddress}/32;
          };
        }
      '';
    };

    # ── Health loop ──────────────────────────────────────────────────────
    # PartOf + After adguardhome: whenever AdGuard is stopped or restarted
    # (deploys, reboots), this unit stops *first*, and its ExecStopPost
    # withdraws the route and waits for the router to converge. Clients are
    # already on another node by the time AdGuard actually goes away.
    systemd.services.dns-anycast-health = {
      description = "Announce anycast DNS only while AdGuard Home answers";
      wantedBy = [ "multi-user.target" ];
      after = [ "bird.service" "adguardhome.service" ];
      bindsTo = [ "bird.service" ];
      partOf = [ "adguardhome.service" ];
      path = [ pkgs.dnsutils ];
      script = ''
        while true; do
          if [ "$(dig +short +time=1 +tries=2 @127.0.0.1 health.home.arpa A)" = "127.0.0.1" ]; then
            ${birdc} enable anycast_dns >/dev/null
          else
            ${birdc} disable anycast_dns >/dev/null
          fi
          sleep 2
        done
      '';
      serviceConfig = {
        Restart = "always";
        RestartSec = 2;
        ExecStopPost = "-${pkgs.writeShellScript "anycast-withdraw" ''
          ${birdc} disable anycast_dns
          sleep 3
        ''}";
      };
    };
  };
}
