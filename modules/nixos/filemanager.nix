{ pkgs, ... }:

{
  # ── Thunar ──────────────────────────────────────────────────────────────
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
