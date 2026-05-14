{ pkgs, ... }:

{
  imports = [
    ./locale.nix
    ./networking.nix
    ./nix-settings.nix
    ./security.nix
    ./fonts.nix
  ];

  # ── Boot ────────────────────────────────────────────────────────────────
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # ── Shell ───────────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # ── Wayland env ─────────────────────────────────────────────────────────
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ── Unfree ──────────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
}
