{ pkgs, ... }:

{
  # ── Fonts ───────────────────────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Nerd Fonts (patched developer fonts with icons)
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.symbols-only

      # UI / System fonts
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf

      # Coding
      jetbrains-mono
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "Liberation Serif" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
      # Subpixel rendering
      subpixel.rgba = "rgb";
      hinting = {
        enable = true;
        style = "slight";
      };
      antialias = true;
    };
  };
}
