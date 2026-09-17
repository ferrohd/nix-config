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

    lan = {
      interface = mkOption { type = types.str; example = "enp1s0"; };
      address = mkOption { type = types.str; };
      prefixLength = mkOption { type = types.ints.between 1 32; default = 24; };
      gateway = mkOption { type = types.str; };
    };

    anycastAddress = mkOption { type = types.str; };

    bgp = {
      nodeAS = mkOption { type = types.ints.unsigned; };
      routerAddress = mkOption { type = types.str; };
      routerAS = mkOption { type = types.ints.unsigned; };
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Networking: static and declarative, no NetworkManager ───────────
    networking = {
      networkmanager.enable = lib.mkForce false;
      useNetworkd = true;
      useDHCP = false;
      firewall = {
        allowedTCPPorts = [ 53 179 ];
        allowedUDPPorts = [ 53 ];
      };
    };

    systemd.network = {
      enable = true;
      netdevs."10-anycast".netdevConfig = { Kind = "dummy"; Name = "anycast0"; };
      networks = {
        "10-lan" = {
          matchConfig.Name = cfg.lan.interface;
          address = [ "${cfg.lan.address}/${toString cfg.lan.prefixLength}" ];
          gateway = [ cfg.lan.gateway ];
          # The node resolves through its own AdGuard; the public fallback
          # keeps auto-upgrade working while AdGuard is down.
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
          # already holds 127.0.0.53:53.
          bind_hosts = [ "127.0.0.1" cfg.lan.address cfg.anycastAddress ];
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

    # ── BGP announcement ─────────────────────────────────────────────────
    services.bird = {
      enable = true;
      config = ''
        router id ${cfg.lan.address};

        protocol device { }

        # Starts disabled; dns-anycast-health enables it once AdGuard answers
        protocol static anycast_dns {
          disabled;
          ipv4;
          route ${cfg.anycastAddress}/32 via "anycast0";
        }

        protocol bgp uplink {
          local ${cfg.lan.address} as ${toString cfg.bgp.nodeAS};
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
