# hosts/blackmesa — AMD/Nvidia workstation, dual 4K, gaming
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "blackmesa";

  # ── Nvidia GPU ──────────────────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # native games are often ELF32 (L4D2's hl2_linux is)
  };
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # Displays attach to the AMD iGPU through the dock, so GLX apps default to
  # it. Offload all Steam games to the 3090 Ti.
  myconfig.gaming.nvidiaOffload.enable = true;

  # ── Game streaming ──────────────────────────────────────────────────────
  # Capture/encode land on the AMD iGPU, since the dock drives both displays
  # from it. Encoder selection is left to Sunshine's autodetection.
  myconfig.sunshine.enable = true;

  # ── Thunderbolt ─────────────────────────────────────────────────────────
  services.hardware.bolt.enable = true;

  # ── Host-specific packages ─────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    lm_sensors
    pciutils
    usbutils
    mesa-demos
    vulkan-tools
  ];

  system.stateVersion = "25.11";
}
