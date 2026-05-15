{ pkgs, ... }:

{
  # ── Audio support packages ──────────────────────────────────────────────
  # PipeWire itself is enabled per-host (blackmesa/laptop) since servers
  # don't need it. This module provides shared GUI mixer packages for
  # desktop hosts.

  # Disable PulseAudio (PipeWire replaces it)
  services.pulseaudio.enable = false;

  # Real-time priority for audio threads
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    pavucontrol # GUI volume mixer
    pwvucontrol # PipeWire-native mixer
    qpwgraph # PipeWire patchbay (replaces helvum)
  ];
}
