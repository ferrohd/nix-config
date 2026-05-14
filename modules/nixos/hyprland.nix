{ config, lib, ... }:

{
  # ── Hyprland (opt-in via myconfig.hyprland.enable) ──────────────────────
  # Activated by mkHost when desktop = true.
  # Keeping it behind an option lets server configs import the module list
  # without accidentally enabling the compositor.
  options.myconfig.hyprland.enable = lib.mkEnableOption "Hyprland compositor";

  config = lib.mkIf config.myconfig.hyprland.enable {
    # ── Wayland compositor ─────────────────────────────────────────────
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # XDG Desktop Portal (screen sharing, file pickers, etc.)
    xdg.portal = {
      enable = true;
      extraPortals = [ ];
    };

    # Required by home-manager useUserPackages + xdg.portal
    environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

    # dconf (GNOME settings backend, used by GTK apps)
    programs.dconf.enable = true;
  };
}
