# modules/nixos/secure-boot.nix
# ── Secure Boot via lanzaboote ───────────────────────────────────────────────
#
# One-time setup (run as root on the target machine):
#
#   1. Put the machine in Secure Boot setup mode (via UEFI firmware menu)
#   2. nix run nixpkgs#sbctl -- create-keys
#   3. nixos-rebuild switch --flake .#<hostname>
#   4. sbctl verify            ← all EFI images should be signed
#   5. Re-enable Secure Boot in firmware
#
# Enable per-host in flake.nix:  secureBoot = true;
{ pkgs, lib, ... }:

{
  # lanzaboote replaces systemd-boot — disable it to avoid conflicts
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # sbctl is used to enroll keys and sign EFI images
  environment.systemPackages = [ pkgs.sbctl ];
}
