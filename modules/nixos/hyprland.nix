{ config, lib, pkgs, ... }:

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
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };

    # XDG Desktop Portal (screen sharing, file pickers, etc.)
    xdg.portal = {
      enable = true;
      # gtk portal provides file pickers and other dialogs for non-Hyprland-native apps
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Required by home-manager useUserPackages + xdg.portal
    environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

    # dconf (GNOME settings backend, used by GTK apps)
    programs.dconf.enable = true;

    # ── GNOME Keyring (libsecret / SSH agent) ──────────────────────────
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
    # Also unlock keyring on TTY login (the path used by autostart-from-TTY setup)
    security.pam.services.su.enableGnomeKeyring = true;
  };
}
