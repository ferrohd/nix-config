{ pkgs, ... }:

{
  home.packages = with pkgs; [
    grimblast
    slurp
    cliphist
    hyprpaper
    wl-clipboard
    swappy
    hyprpicker
    wf-recorder
  ];

  services.swayosd.enable = true;
}
