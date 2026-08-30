{ config, lib, ... }:

{
  # ── Sunshine (opt-in via myconfig.sunshine.enable) ──────────────────────
  # Self-hosted game-stream host for Moonlight clients.
  #
  # Runs as a systemd *user* unit that is partOf graphical-session.target, so
  # it always stops when the compositor exits. autoStart is off, so it is not
  # wantedBy that target either — nothing launches it implicitly. Start it on
  # demand with `systemctl --user start sunshine` and stop it when done, which
  # keeps the capture stack and its open ports idle during normal desktop use.
  #
  # settings/applications are deliberately left unset: the NixOS module only
  # hands Sunshine a config file once they are populated, and doing so makes
  # the web UI at https://localhost:47990 read-only.
  options.myconfig.sunshine.enable =
    lib.mkEnableOption "Sunshine game-stream host for Moonlight";

  config = lib.mkIf config.myconfig.sunshine.enable {
    services.sunshine = {
      enable = true;
      autoStart = false;
      # DRM/KMS capture on Wayland needs CAP_SYS_ADMIN; the module installs a
      # setcap wrapper rather than granting it to the user. Side effect: apps
      # launched from Moonlight run under AT_SECURE, so custom commands need a
      # `sudo -u ferro` prefix.
      capSysAdmin = true;
      # TCP 47984/47989/47990/48010 + UDP 47998-48000/48002/48010. The module
      # also pulls in avahi (UDP 5353) for Moonlight autodiscovery.
      openFirewall = true;
    };
  };
}
