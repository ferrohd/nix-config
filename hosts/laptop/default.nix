# hosts/laptop — portable workstation, power-optimised
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";

  # ── Power management ────────────────────────────────────────────────────
  services.thermald.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = { governor = "powersave"; turbo = "never"; };
      charger = { governor = "performance"; turbo = "auto"; };
    };
  };
  services.upower.enable = true;

  # ── Lid switch ──────────────────────────────────────────────────────────
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "suspend";
  };

  # ── Graphics (integrated — override per-machine) ────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

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

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    powertop
  ];

  system.stateVersion = "25.11";
}
