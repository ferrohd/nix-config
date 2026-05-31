# hosts/laptop/home.nix — host-level home-manager config (display layout, hardware-specific HM settings)
{ ... }:

{
  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland.settings.monitor = [
        {
          output = "eDP-1";
          mode = "preferred";
          position = "auto";
          scale = 1.5;
        }
      ];
    }
  ];
}
