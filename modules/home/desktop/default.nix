{ pkgs, lib, ... }:

{
  imports = [
    ./waybar
    ./dunst.nix
    ./rofi.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./extras.nix
  ];

  # ── Auto-start Hyprland from TTY1 ──────────────────────────────────────
  programs.zsh.initContent = lib.mkAfter ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
      exec Hyprland
    fi
  '';

  # ── Hyprland user config ────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;

    settings = {
      "$mainMod" = "SUPER";

      env = [
        "XCURSOR_THEME,catppuccin-mocha-dark-cursors"
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_THEME,Catppuccin Mocha Dark"
        "HYPRCURSOR_SIZE,24"
      ];

      cursor.no_hardware_cursors = false;

      exec-once = [
        "waybar"
        "dunst"
        "hyprpaper"
        "hypridle"
        "hyprpolkitagent"
        "cliphist wipe"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = lib.mkForce "rgba(cba6f7ff) rgba(89b4faff) 45deg";
        "col.inactive_border" = lib.mkForce "rgba(585b70ff)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        fullscreen_opacity = 1.0;

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = false;
          xray = false;
        };

        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          color = lib.mkForce "rgba(00000055)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.15"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
        ];
        animation = [
          "windows, 1, 4, overshot, slide"
          "windowsOut, 1, 4, smoothOut, slide"
          "fade, 1, 4, smoothIn"
          "workspaces, 1, 6, overshot, slide"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
        ];
      };

      input = {
        kb_layout = "it";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
        sensitivity = 0;
        accel_profile = "flat";
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vfr = true;
      };

      bind = [
        "$mainMod, Return, exec, ghostty"
        "$mainMod, Q, killactive,"
        "$mainMod, D, togglefloating,"
        "$mainMod, F, fullscreen,"
        "$mainMod, L, exec, hyprlock"
        "$mainMod, Space, exec, rofi -show drun"
        "$mainMod SHIFT, Space, exec, rofi -show window"
        "$mainMod SHIFT, Escape, exec, $HOME/.config/rofi/powermenu.sh"
        "$mainMod SHIFT, V, exec, cliphist list | rofi -dmenu -theme cliphist | cliphist decode | wl-copy"

        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume +5"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume -5"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"

        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

        ", Print, exec, grimblast copy area"
        "Shift, Print, exec, grimblast save output"
        "$mainMod, Print, exec, grimblast save area | swappy -f -"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };

    # Hyprland v0.54 requires match: prefix for windowrule and layerrule matchers
    extraConfig = ''
      layerrule = blur on, match:namespace waybar
      layerrule = blur on, match:namespace dunst
      layerrule = ignore_alpha 0, match:namespace waybar
      layerrule = ignore_alpha 0, match:namespace dunst

      windowrule = match:class ^(kitty)$, opacity 1.0 override 0.9 override 0.9 override
      windowrule = match:class ^(ghostty)$, opacity 1.0 override 0.9 override 0.9 override
      windowrule = match:class ^(pavucontrol)$, float on
      windowrule = match:class ^(blueman-manager)$, float on
      windowrule = match:title ^(Picture-in-Picture)$, float on
      windowrule = match:title ^(Picture-in-Picture)$, pin on
      windowrule = match:title ^(Volume Control)$, float on
      windowrule = match:class ^(pavucontrol)$, center on
      windowrule = match:class ^(rofi)$, no_blur on
      windowrule = match:class ^(waybar)$, no_blur on
      windowrule = match:fullscreen 1, immediate on
    '';
  };

  # ── GTK ─────────────────────────────────────────────────────────────────
  # gtk4.theme = null is the HM 26.05+ default; Stylix manages GTK4 theming directly.
  gtk.gtk4.theme = null;

  # ── Stylix ──────────────────────────────────────────────────────────────
  # Tell Stylix which Firefox profile to theme (only set on desktop where Stylix HM module is loaded)
  stylix.targets.firefox.profileNames = [ "ferro" ];

  # ── Cursor ──────────────────────────────────────────────────────────────
  home.pointerCursor = {
    package = lib.mkForce pkgs.catppuccin-cursors.mochaDark;
    name = lib.mkForce "catppuccin-mocha-dark-cursors";
    size = lib.mkForce 24;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor = {
      enable = true;
      size = 24;
    };
  };
}
