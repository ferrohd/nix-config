{ pkgs, inputs, ... }:

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

  };

  # ── Shell ───────────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # ── Wayland env ─────────────────────────────────────────────────────────
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ── Nixpkgs ─────────────────────────────────────────────────────────────
  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ../../overlays { inherit (inputs) opencode nixpkgs-unstable; };
  };
}
