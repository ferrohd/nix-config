_:

{
  # ── Newsboat (RSS/Atom feed reader) ─────────────────────────────────────
  # Catppuccin theming is injected automatically by inputs.catppuccin's
  # homeModule (flavor "mocha" inherited from catppuccinDefaults in
  # lib/default.nix) whenever both catppuccin.enable and
  # programs.newsboat.enable are true.
  programs.newsboat = {
    enable = true;
    autoReload = true;
  };
}
