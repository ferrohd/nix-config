{ pkgs, ... }:

{
  # ── Thunar ──────────────────────────────────────────────────────────────
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true; # required by the udiskie user service

  environment.systemPackages = with pkgs; [
    file-roller # backend for thunar-archive-plugin (the plugin is a frontend only)
    ffmpegthumbnailer # video thumbnails for tumbler
  ];
}
