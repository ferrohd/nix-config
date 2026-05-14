{ pkgs, ... }:

{
  # ── Security ────────────────────────────────────────────────────────────
  security = {
    # Polkit for privilege escalation (used by Hyprland, etc.)
    polkit.enable = true;

    # Real-time kit (audio latency)
    rtkit.enable = true;

    # Disable sudo lecture, keep timeout short
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = true;
      extraConfig = ''
        Defaults timestamp_timeout=15
        Defaults lecture=never
      '';
    };
  };

  # Kernel hardening — prevent IP spoofing, disable ICMP redirects, SYN flood protection
  boot.kernel.sysctl = {
    # Prevent IP spoofing
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # Disable ICMP redirects
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;

    # Disable source routing
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;

    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;

    # Restrict dmesg
    "kernel.dmesg_restrict" = 1;
  };

  environment.systemPackages = with pkgs; [
    age    # Modern encryption
    rage   # Rust implementation of age
  ];
}
