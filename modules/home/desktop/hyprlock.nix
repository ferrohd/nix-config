{ lib, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    package = pkgs.unstable.hyprlock;

    settings = lib.mkForce {
      general = {
        hide_cursor = true;
        no_fade_in = false;
        ignore_empty_input = false;
        grace = 0;
        disable_loading_bar = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 4;
          blur_size = 8;
          noise = 1.17e-2;
          contrast = 0.9;
          brightness = 0.5;
          vibrancy = 0.2;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "300, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          fade_on_empty = true;
          placeholder_text = "<i>Password...</i>";
          hide_input = false;
          position = "0, -180";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +'%H:%M')\"";
          font_size = 120;
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +'%A, %d %B %Y')\"";
          font_size = 20;
          position = "0, 160";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "  Locked";
          font_size = 14;
          position = "0, 220";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
