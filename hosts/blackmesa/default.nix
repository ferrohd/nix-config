# hosts/blackmesa — AMD/Nvidia workstation, dual 4K, gaming
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "blackmesa";

  # ── Nvidia GPU ──────────────────────────────────────────────────────────
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    package = pkgs.unstable.linuxPackages_latest.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # ── PipeWire ────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ── File manager ────────────────────────────────────────────────────────
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # ── Stylix (global theming) ─────────────────────────────────────────────
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = {
      slug = "catppuccin-mocha";
      scheme = "Catppuccin Mocha";
      author = "Catppuccin";
      base00 = "1e1e2e";
      base01 = "181825";
      base02 = "313244";
      base03 = "45475a";
      base04 = "585b70";
      base05 = "cdd6f4";
      base06 = "f5e0dc";
      base07 = "b4befe";
      base08 = "f38ba8";
      base09 = "fab387";
      base0A = "f9e2af";
      base0B = "a6e3a1";
      base0C = "94e2d5";
      base0D = "89b4fa";
      base0E = "cba6f7";
      base0F = "f2cdcd";
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 12;
        terminal = 14;
        desktop = 11;
        popups = 12;
      };
    };
    cursor = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
    };
    opacity = {
      terminal = 0.85;
      popups = 0.95;
    };
  };

  # ── Host-specific packages ─────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    lm_sensors
    pciutils
    usbutils
  ];

  system.stateVersion = "25.11";
}
