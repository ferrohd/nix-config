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
      exec start-hyprland
    fi
  '';

  # ── Hyprland user config ────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    # nixos-26.05 ships Hyprland 0.55.2 (full lua mode); unstable lags at 0.54.3 (partial lua).
    package = pkgs.hyprland;
    configType = "lua";

    settings = {
      # ── Variables (render as `local mod = "SUPER"`) ─────────────────────
      mod = { _var = "SUPER"; };

      # ── Structured sections (single hl.config call) ─────────────────────
      config = {
        general = {
          gaps_in = 6;
          gaps_out = 12;
          border_size = 2;
          layout = "dwindle";
          col = {
            active_border = {
              colors = [
                (lib.generators.mkLuaInline "colors.mauve")
                (lib.generators.mkLuaInline "colors.blue")
              ];
              angle = 45;
            };
            inactive_border = lib.generators.mkLuaInline "colors.surface2";
          };
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
            color = "rgba(00000055)";
          };
        };

        animations.enabled = true;

        input = {
          kb_layout = "it";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";
          follow_mouse = 1;
          sensitivity = 0;
          accel_profile = "flat";
          touchpad.natural_scroll = true;
        };

        dwindle = {
          preserve_split = true;
          force_split = 2;
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };

        xwayland.force_zero_scaling = true;

        cursor.no_hardware_cursors = 0;
      };

      # ── Beziers (one hl.curve per entry) ────────────────────────────────
      curve = [
        { _args = [ "overshot"  { type = "bezier"; points = [ [ 0.05 0.9 ] [ 0.1  1.15    ] ]; } ]; }
        { _args = [ "smoothOut" { type = "bezier"; points = [ [ 0.36 0   ] [ 0.66 (-0.56) ] ]; } ]; }
        { _args = [ "smoothIn"  { type = "bezier"; points = [ [ 0.25 1   ] [ 0.5  1       ] ]; } ]; }
      ];

      # ── Animations (one hl.animation per entry) ─────────────────────────
      animation = [
        { leaf = "windows";     enabled = true; speed = 4;  bezier = "overshot";  style = "slide"; }
        { leaf = "windowsOut";  enabled = true; speed = 4;  bezier = "smoothOut"; style = "slide"; }
        { leaf = "fade";        enabled = true; speed = 4;  bezier = "smoothIn"; }
        { leaf = "workspaces";  enabled = true; speed = 6;  bezier = "overshot";  style = "slide"; }
        { leaf = "border";      enabled = true; speed = 10; bezier = "default"; }
        { leaf = "borderangle"; enabled = true; speed = 8;  bezier = "default"; }
      ];

      # ── Env vars (two-arg form via _args) ───────────────────────────────
      env = [
        { _args = [ "XCURSOR_SIZE" "24" ]; }
        { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
        { _args = [ "STEAM_FORCE_DESKTOPUI_SCALING" "1.5" ]; } # scale Steam UI to match Hyprland fractional scale
      ];

      # ── Autostart (single hl.on hook wrapping all execs) ────────────────
      on = {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("waybar")
              hl.exec_cmd("dunst")
              hl.exec_cmd("hypridle")
              hl.exec_cmd("hyprpolkitagent")
              hl.exec_cmd("nm-applet --indicator")
              hl.exec_cmd("blueman-applet")
              hl.exec_cmd("cliphist wipe")
              hl.exec_cmd("wl-paste --type text --watch cliphist store")
              hl.exec_cmd("wl-paste --type image --watch cliphist store")
            end
          '')
        ];
      };

      # ── Window rules (combined per matcher) ─────────────────────────────
      window_rule = [
        { match.class = "^(kitty)$";              opacity = "1.0 override 0.9 override 0.9 override"; }
        { match.class = "^(ghostty)$";            opacity = "1.0 override 0.9 override 0.9 override"; }
        { match.class = "^(pavucontrol)$";        float = true; center = true; }
        { match.class = "^(blueman-manager)$";    float = true; }
        { match.title = "^(Picture-in-Picture)$"; float = true; pin = true; }
        { match.title = "^(Volume Control)$";     float = true; }
        { match.class = "^(rofi)$";               no_blur = true; }
        { match.class = "^(waybar)$";             no_blur = true; }
        { match.fullscreen = true;                immediate = true; }
      ];

      # ── Layer rules ─────────────────────────────────────────────────────
      layer_rule = [
        { match.namespace = "waybar"; blur = true; ignore_alpha = 0; }
        { match.namespace = "dunst";  blur = true; ignore_alpha = 0; }
      ];
    };

    # ── Binds (raw Lua — cleaner than _args + mkLuaInline for 60+ entries) ─
    extraConfig = ''
      -- Applications
      hl.bind(mod .. " + Return",         hl.dsp.exec_cmd("ghostty"))
      hl.bind(mod .. " + Q",              hl.dsp.window.close())
      hl.bind(mod .. " + D",              hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mod .. " + F",              hl.dsp.window.fullscreen())
      hl.bind(mod .. " + L",              hl.dsp.exec_cmd("hyprlock"))
      hl.bind(mod .. " + Space",          hl.dsp.exec_cmd("rofi -show drun"))
      hl.bind(mod .. " + SHIFT + Space",  hl.dsp.exec_cmd("rofi -show window"))
      hl.bind(mod .. " + SHIFT + Escape", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/rofi/powermenu.sh"))
      hl.bind(mod .. " + SHIFT + V",      hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

      -- Focus / move (directional)
      for _, dir in ipairs({ "left", "right", "up", "down" }) do
        hl.bind(mod .. " + " .. dir,         hl.dsp.focus({ direction = dir }))
        hl.bind(mod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
      end

      -- Workspaces 1..10 (key 0 → workspace 10)
      for i = 1, 10 do
        local key = i % 10
        hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      -- Mouse scroll workspace
      hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

      -- Media (transport: locked; vol/brightness: locked + repeating)
      hl.bind("XF86AudioMute",  hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
      hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"),      { locked = true })
      hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
      hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
      hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"),       { locked = true })

      hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume +5"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume -5"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"),             { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),             { locked = true, repeating = true })

      -- Screenshots
      hl.bind("Print",           hl.dsp.exec_cmd("grimblast copy area"))
      hl.bind("SHIFT + Print",   hl.dsp.exec_cmd("grimblast save output"))
      hl.bind(mod .. " + Print", hl.dsp.exec_cmd("grimblast save area | swappy -f -"))

      -- Mouse drag/resize
      hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
    '';
  };

  # ── Hyprpaper ───────────────────────────────────────────────────────────
  services.hyprpaper = {
    enable = true;
    package = pkgs.hyprpaper;
    settings = {
      wallpaper = [
        {
          monitor = "DP-1";
          path = "${./wallpaper.png}";
          fit_mode = "cover";
        }
        {
          monitor = "DP-2";
          path = "${./wallpaper.png}";
          fit_mode = "cover";
        }
      ];
    };
  };

  # ── Qt (Kvantum) ───────────────────────────────────────────────────────
  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };

  # ── GTK ────────────────────────────────────────────────────────────────
  gtk.enable = true;

  # ── Cursor ──────────────────────────────────────────────────────────────
  catppuccin.cursors = {
    enable = true;
    accent = "dark";
  };
  home.pointerCursor = {
    size = 24;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor = {
      enable = true;
      size = 24;
    };
  };
}
