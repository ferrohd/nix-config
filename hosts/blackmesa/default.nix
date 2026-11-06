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
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # ships `nvidia-offload <cmd>` for non-Steam programs
      };
      amdgpuBusId = "PCI:122@0:0:0"; # AMD Radeon Graphics (iGPU), PCI 0000:7a:00.0 — drives both monitors
      nvidiaBusId = "PCI:1@0:0:0"; # RTX 3090 Ti (dGPU), PCI 0000:01:00.0 — compute/offload only
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # Displays attach to the AMD iGPU through the dock, so GLX apps default to
  # it. Offload all Steam games to the 3090 Ti.
  myconfig.gaming.nvidiaOffload.enable = true;

  # ── Game streaming ──────────────────────────────────────────────────────
  # Capture/encode land on the AMD iGPU, since the dock drives both displays
  # from it. Encoder selection is left to Sunshine's autodetection.
  myconfig.sunshine.enable = true;

  # ── Reverse engineering ─────────────────────────────────────────────────
  # Full kit; see modules/nixos/reverse-engineering.nix for the sub-group
  # toggles if the closure needs trimming.
  myconfig.reverseEngineering.enable = true;

  # ── Firewall ────────────────────────────────────────────────────────────
  # Steam ports come from programs.steam.*.openFirewall in modules/nixos/gaming.nix.
  networking.firewall.allowedUDPPorts = [
    24872 # Eden emulator LDN room (when hosting)
    7777 # Absolum online co-op — direct/LAN peers
  ];

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
    # Hardware/firmware info
    lshw
    inxi
    hwinfo
    dmidecode
    # Disk health
    smartmontools
    nvme-cli
    # Network monitoring/diagnostics
    nethogs
    iftop
    bandwhich
    iperf3
    # System diagnostics
    powertop
    iotop
    ncdu
    tree
  ];

  system.stateVersion = "25.11";
}
