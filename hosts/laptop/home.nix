# hosts/laptop/home.nix — host-level home-manager config (display layout, hardware-specific HM settings)
{ ... }:

{
  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland.settings.monitor = [
        "eDP-1, preferred, auto, 1.5"
      ];
    }
  ];
}
