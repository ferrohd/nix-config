{ lib, isDesktop, ... }:

{
  # ── Halloy (IRC client) ──────────────────────────────────────────────────
  # Catppuccin theming is injected automatically by inputs.catppuccin's
  # homeModule (flavor "mocha" inherited from catppuccinDefaults in
  # lib/default.nix). That module writes ~/.config/halloy/themes/
  # catppuccin-mocha.toml and sets settings.theme = "catppuccin-mocha"
  # whenever both catppuccin.enable and programs.halloy.enable are true.
  programs.halloy = lib.mkIf isDesktop {
    enable = true;
    settings = {
      servers = {
        liberachat = {
          nickname = "ferro";
          server = "irc.libera.chat";
          port = 6697;
          use_tls = true;
          channels = [ ];
        };
        hackint = {
          nickname = "ferro";
          server = "irc.hackint.org";
          port = 6697;
          use_tls = true;
          channels = [ ];
        };
      };

      buffer.channel.topic.enabled = true;
      sidebar.width = 200;
    };
  };
}
