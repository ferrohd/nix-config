# hosts/blackmesa/home.nix — host-level home-manager config (display layout, hardware-specific HM settings)
{ lib, ... }:

{
  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland.settings.monitor = [
        {
          output = "DP-2";
          mode = "3840x2160@60";
          position = "0x0";
          scale = 1.5;
          transform = 1;
          bitdepth = 10;
          cm = "hdr";
          sdrbrightness = 1.0;
          sdrsaturation = 1.0;
        }
        {
          output = "DP-1";
          mode = "3840x2160@60";
          position = "1440x0";
          scale = 1.5;
          bitdepth = 10;
          cm = "hdr";
          sdrbrightness = 1.0;
          sdrsaturation = 1.0;
        }
      ];
    }
  ];
}
