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
