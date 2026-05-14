# overlays/default.nix
# ── Package overlays: patch, pin, or add packages to nixpkgs ─────────────
{ opencode, ... }:

[
  # ── OpenCode (from its own flake) ────────────────────────────────────────
  (_final: _prev: {
    opencode = opencode.packages.${_final.system}.default;
  })

  # ── Custom packages from pkgs/ ───────────────────────────────────────────
  (final: _prev: {
    custom-package = final.callPackage ../pkgs/custom-package { };
  })

  # ── Additional overlays (examples) ──────────────────────────────────────
  # (final: prev: {
  #   # Pin a package to stable
  #   # discord = prev.pkgs-stable.discord;
  #
  #   # Override a package
  #   # mpv = prev.mpv.override {
  #   #   scripts = with prev.mpvScripts; [ mpris sponsorblock ];
  #   # };
  # })
]
