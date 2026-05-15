# overlays/default.nix
# ── Package overlays: patch, pin, or add packages to nixpkgs ─────────────
{ opencode, nixpkgs-unstable, ... }:

[
  # ── Unstable packages ─────────────────────────────────────────────────────
  # Provides pkgs.unstable.* for packages that need bleeding-edge versions.
  # Used for: Hyprland desktop stack, Ghostty, kernel + Nvidia drivers, etc.
  (final: _prev: {
    unstable = import nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  })

  # ── OpenCode (from its own flake) ────────────────────────────────────────
  (_final: _prev: {
    opencode = opencode.packages.${_final.system}.default;
  })

  # ── Custom packages from pkgs/ ───────────────────────────────────────────
  (final: _prev: {
    custom-package = final.callPackage ../pkgs/custom-package { };
  })
]
