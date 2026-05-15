_:

{
  # ── Gaming ──────────────────────────────────────────────────────────────
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true; # Gamescope compositor for Steam
    remotePlay.openFirewall = true;
  };

  # gamemode: CPU/GPU performance governor while a game is running
  programs.gamemode.enable = true;
}
