{ lib, ... }:

{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 350;
        height = 300;
        origin = "top-right";
        offset = "12x56";
        scale = 0;
        notification_limit = 20;
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 0;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        indicate_hidden = "yes";
        transparency = 15;
        corner_radius = 14;
        separator_height = 2;
        padding = 16;
        horizontal_padding = 16;
        text_icon_padding = 8;
        frame_width = 2;
        gap_size = 6;
        separator_color = lib.mkForce "frame";
        sort = "urgency";
        line_height = 4;
        markup = "full";
        show_age_threshold = 60;
        word_wrap = true;
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 48;
        icon_path = "/usr/share/icons/Hicolor/16x16/status/:/usr/share/icons/Hicolor/16x16/devices/";
        browser = "firefox";
        dmenu = "rofi -dmenu";
        layer = "overlay";
        force_xwayland = false;
        mouse_left_click = "close_current";
        mouse_middle_click = "close_all";
        mouse_right_click = "context";
      };

      urgency_low = {
        timeout = 5;
      };

      urgency_normal = {
        timeout = 8;
      };

      urgency_critical = {
        timeout = 0;
      };
    };
  };
}
