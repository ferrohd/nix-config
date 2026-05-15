{ pkgs, lib, ... }:

{
  programs.rofi = {
    enable = true;
    # rofi-wayland has been merged into rofi on unstable — pin from there
    package = pkgs.unstable.rofi;
    plugins = [ pkgs.unstable.rofi-calc ];
    font = lib.mkForce "JetBrainsMono Nerd Font 13";
    terminal = "ghostty";
    extraConfig = {
      modi = "drun,window,run,calc";
      show-icons = true;
      drun-display-format = "{name}";
      window-display-format = "{name}";
      display-drun = "   ";
      display-window = "   ";
      display-run = "   ";
      display-calc = "   ";
      sidebar-mode = false;
    };
  };
}
