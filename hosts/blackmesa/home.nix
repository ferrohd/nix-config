# hosts/blackmesa/home.nix — host-level home-manager config (display layout, hardware-specific HM settings)
{ lib, ... }:

{
  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland.settings.monitor = [
        "DP-2, 3840x2160@60, 0x0, 1.5, transform, 1, bitdepth, 10, cm, hdr, sdrbrightness, 1.0, sdrsaturation, 1.0"
        "DP-1, 3840x2160@60, 1440x0, 1.5, bitdepth, 10, cm, hdr, sdrbrightness, 1.0, sdrsaturation, 1.0"
      ];
    }
  ];
}
