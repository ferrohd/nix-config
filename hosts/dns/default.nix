# hosts/dns — profile shared by every node in ./nodes.nix
{ lib, hostname, ... }:

let
  inherit (import ./nodes.nix) site nodes;
  node = nodes.${hostname};

  # Position in the node list. Used to stagger auto-upgrades so two nodes
  # never rebuild or reboot at the same moment.
  slot = lib.lists.findFirstIndex (n: n == hostname) 0 (lib.attrNames nodes);
in
{
  imports = [
    ../../modules/nixos/anycast-dns.nix
    ./adguard.nix
  ];

  networking.hostName = hostname;

  myconfig.anycastDns = {
    enable = true;
    lan = {
      inherit (node) interface address;
      inherit (site.lan) prefixLength gateway;
    };
    inherit (site) anycastAddress bgp;
  };

  # mkHost pulls docker.nix into every host; a DNS appliance doesn't need it
  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.podman.enable = lib.mkForce false;

  # ── GitOps: pull main, converge ─────────────────────────────────────────
  # No --update-input: flake.lock bumps arrive through git like any change.
  # Slots are 5 min apart on a 15 min cycle (node 0 at :00, node 1 at :05, …).
  system.autoUpgrade = {
    enable = true;
    flake = "github:ferrohd/nix-config#${hostname}";
    dates = "*:${lib.fixedWidthNumber 2 (lib.mod (slot * 5) 15)}/15";
    allowReboot = true;
  };

  system.stateVersion = node.stateVersion;
}
