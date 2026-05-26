# hosts/blackmesa — AMD/Nvidia workstation, dual 4K, gaming
{ config, pkgs, ... }:

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
    package = config.boot.kernelPackages.nvidiaPackages.stable;
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

  # ── Thunderbolt ─────────────────────────────────────────────────────────
  services.hardware.bolt.enable = true;

  # ── Host-specific packages ─────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    lm_sensors
    pciutils
    usbutils
  ];

  system.stateVersion = "25.11";
}
