{ pkgs, lib, ... }:

{
  # ── Powermenu script ────────────────────────────────────────────────────
  home.file.".config/rofi/powermenu.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Rofi-based powermenu

      lock="  Lock"
      suspend="  Suspend"
      hibernate="  Hibernate"
      reboot="  Reboot"
      shutdown="  Shutdown"

      chosen=$(printf '%s\n' "$lock" "$suspend" "$hibernate" "$reboot" "$shutdown" \
        | rofi -dmenu \
               -p "Power" \
               -i \
               -theme-str 'window { width: 220px; } listview { lines: 5; }')

      case "$chosen" in
        "$lock")      hyprlock ;;
        "$suspend")   systemctl suspend ;;
        "$hibernate") systemctl hibernate ;;
        "$reboot")    systemctl reboot ;;
        "$shutdown")  systemctl poweroff ;;
      esac
    '';
  };

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
