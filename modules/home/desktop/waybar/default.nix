{ pkgs, ... }:

{
  stylix.targets.waybar.addCss = false;

  programs.waybar = {
    enable = true;
    package = pkgs.unstable.waybar;
    style = builtins.readFile ./style.css;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        margin-top = 6;
        margin-left = 12;
        margin-right = 12;
        spacing = 8;
        modules-left = [
          "custom/launcher"
          "hyprland/workspaces"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "custom/cliphist"
          "cpu"
          "memory"
          "pulseaudio"
          "clock"
          "tray"
        ];

        "custom/launcher" = {
          format = "  ";
          on-click = "rofi -show drun";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
          };
          on-click = "activate";
          all-outputs = true;
        };

        "hyprland/window" = {
          format = "{}";
          separate-outputs = true;
        };

        cpu = {
          interval = 5;
          format = " {usage}%";
          tooltip = true;
        };

        memory = {
          interval = 10;
          format = " {}%";
          tooltip = true;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}% ";
          format-bluetooth-muted = " {icon} ";
          format-muted = " {volume}%";
          format-icons = {
            headphones = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          scroll-step = 5;
          on-click = "pavucontrol";
        };

        clock = {
          format = " {:%H:%M}";
          format-alt = " {:%d/%m/%Y}";
          tooltip-format = "{:%A, %d %B %Y}";
          interval = 30;
        };

        tray = {
          spacing = 8;
        };

        "custom/cliphist" = {
          format = "";
          on-click = "cliphist list | rofi -dmenu -theme cliphist | cliphist decode | wl-copy";
          tooltip = false;
        };
      };
    };
  };

}
