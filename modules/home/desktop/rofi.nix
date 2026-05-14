{ pkgs, lib, ... }:

{
  programs.rofi = {
    enable = true;
    # FIX: rofi-wailand has been merged into rofi package
    package = pkgs.rofi;
    plugins = [ pkgs.rofi-calc ];
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
