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

  environment.systemPackages = with pkgs; [
    acpi
    powertop
  ];

  system.stateVersion = "25.11";
}
