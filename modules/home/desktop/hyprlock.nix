{ pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    package = pkgs.unstable.hyprlock;

    settings = {
      background = [
        {
          path = "${./wallpaper.png}";
          blur_passes = 3;
          blur_size = 8;
          brightness = 0.6;
          contrast = 0.9;
          noise = 1.17e-2;
          vibrancy = 0.17;
          vibrancy_darkness = 0.0;
        }
      ];
    };
  };
}
