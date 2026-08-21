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
      gamescopeSession.enable = true; # Gamescope compositor for Steam
      remotePlay.openFirewall = true;

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
