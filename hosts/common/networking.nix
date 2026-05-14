{ lib, ... }:

{
  networking = {
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowPing = true;
      # Default: no open ports. Hosts override as needed.
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      # Logging
      logReversePathDrops = true;
    };

    # Disable legacy wpa_supplicant (NetworkManager handles wifi)
    wireless.enable = lib.mkForce false;
  };

  # Resolved for mDNS / DNS-over-TLS
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "allow-downgrade";
      FallbackDNS = "1.1.1.1 9.9.9.9";
    };
  };

  # Tailscale VPN (optional — enable per-host if needed)
  services.tailscale.enable = lib.mkDefault false;

  # SSH daemon (enabled, hardened — key-only, no root, max 3 attempts)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      MaxAuthTries = 3;
    };
    openFirewall = true;
  };
}
