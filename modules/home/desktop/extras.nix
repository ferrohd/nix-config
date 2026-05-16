{ pkgs, ... }:

{
  home.packages = [
    # ── Hyprland utilities (from unstable to match compositor version) ──
    pkgs.unstable.grimblast
    pkgs.unstable.hyprpaper
    pkgs.unstable.hyprpicker
    pkgs.unstable.hyprpolkitagent

    # ── Wayland tools (stable is fine) ─────────────────────────────────
    pkgs.slurp
    pkgs.cliphist
    pkgs.wl-clipboard
    pkgs.swappy
    pkgs.wf-recorder
  ];

  services.swayosd.enable = true;
}
