# hosts/blackmesa/home.nix — host-level home-manager config (display layout, hardware-specific HM settings)
_:

{
  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland.settings.monitor = [
        {
          # Matched by EDID description (prefix match, up to the serial),
          # not port name "DP-2" — survives the connector being renamed
          # after a Thunderbolt dock replug/relink.
          output = "desc:LG Electronics LG ULTRAFINE 408NTWG8W265";
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
          # See DP-2 comment above — same rename-resilience rationale.
          output = "desc:LG Electronics LG ULTRAFINE 407NTRLDV854";
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
