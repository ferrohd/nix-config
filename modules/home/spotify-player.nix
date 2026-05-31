{ lib, isDesktop, hostname, ... }:

{
  programs.spotify-player = lib.mkIf isDesktop {
    enable = true;

    settings = {
      # ── UI ──────────────────────────────────────────────────────────────
      border_type = "Rounded";

      # ── Notifications ───────────────────────────────────────────────────
      enable_notify = true;
      notify_timeout_in_secs = 5;
      notify_streaming_only = true;

      # ── Streaming / device ──────────────────────────────────────────────
      enable_streaming = "Always";
      enable_media_control = true;

      device = {
        name = hostname;
        device_type = "computer";
        volume = 100;
        bitrate = 320;
        audio_cache = false;
        normalization = true;
        autoplay = false;
      };
    };
  };
}
