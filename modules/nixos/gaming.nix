{ config, lib, pkgs, ... }:

{
  # ── Gaming ──────────────────────────────────────────────────────────────
  # nvidiaOffload is opt-in per host: it pins the GLX vendor to NVIDIA, which
  # would break OpenGL on hosts with no NVIDIA GPU (laptop is integrated-only
  # but still gets this module, since mkHost imports it for desktop = true).
  options.myconfig.gaming.nvidiaOffload.enable =
    lib.mkEnableOption "NVIDIA PRIME render offload for all Steam games";

  config = {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;

      # Firewall flags are declarative; see nixos/modules/programs/steam.nix.
      # Steam Datagram Relay (UDP 3478/4379/4380) is deliberately absent
      # upstream — it is outbound-only and handled by conntrack.
      remotePlay.openFirewall = true; # TCP 27036-27037; UDP 10400-10401, 27031-27036
      dedicatedServer.openFirewall = true; # TCP+UDP 27015
      # Shared on purpose: must be open on both ends to copy games over LAN.
      localNetworkGameTransfers.openFirewall = true; # TCP 27040; UDP 27036

      # extraEnv lands in the FHS env profile wrapped in `set -a`, so it is
      # exported to Steam and inherited by every game it launches.
      package = lib.mkIf config.myconfig.gaming.nvidiaOffload.enable (
        pkgs.steam.override {
          extraEnv = {
            __NV_PRIME_RENDER_OFFLOAD = "1";
            __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          };
        }
      );
    };

    # gamemode: CPU/GPU performance governor while a game is running
    programs.gamemode.enable = true;
  };
}
