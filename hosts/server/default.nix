# hosts/server — headless infrastructure node
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Networking ──────────────────────────────────────────────────────────
  networking = {
    hostName = "server";
    firewall.allowedTCPPorts = [ 22 80 443 ];
    firewall.allowedUDPPorts = [ 443 ]; # QUIC / HTTP3
  };

  services.tailscale.enable = true;

  # ── Nginx reverse proxy ────────────────────────────────────────────────
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "aleferrara1998@gmail.com";
  };

  # ── Fail2ban ────────────────────────────────────────────────────────────
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment.enable = true;
  };

  # ── Automatic updates ──────────────────────────────────────────────────
  system.autoUpgrade = {
    enable = true;
    flake = "github:YOUR_USER/nixos-config#server";
    flags = [ "--update-input" "nixpkgs" ];
    dates = "04:00";
    allowReboot = true;
    rebootWindow = { lower = "03:00"; upper = "05:00"; };
  };

  # ── Minimal packages ───────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    vim
    htop
    tmux
    curl
    git
    ncdu
    iotop
  ];

  system.stateVersion = "25.11";
}
