{ pkgs, ... }:

{
  home.packages = [
    # ── Hyprland utilities (from unstable to match compositor version) ──
    pkgs.unstable.grimblast
    pkgs.unstable.hyprpicker
    pkgs.unstable.hyprpolkitagent

    # ── Wayland tools (stable is fine) ─────────────────────────────────
    pkgs.slurp
    pkgs.cliphist
    pkgs.wl-clipboard
    pkgs.swappy
    pkgs.wf-recorder
    pkgs.libnotify # notify-send, used by the scripts below
    pkgs.wtype # lets rofi-emoji's "insert" action type into the focused window

    # ── Archives (file-roller/thunar shell out to these) ────────────────
    pkgs.unrar

    # ── Media / tray ────────────────────────────────────────────────────
    pkgs.playerctl
    pkgs.networkmanagerapplet
  ];

  # ── Screen recording toggle (wf-recorder has no built-in toggle) ───────
  home.file.".config/hypr/record.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Toggle wf-recorder on the focused monitor. SIGINT is required to
      # finalise the container — pkill without -INT produces a corrupt file.

      if pkill -INT -x wf-recorder 2>/dev/null; then
        notify-send "Screen recording" "Stopped — saved to ~/Videos"
        exit 0
      fi

      mkdir -p "$HOME/Videos"
      out="$HOME/Videos/rec-$(date +%Y%m%d-%H%M%S).mp4"
      mon=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

      notify-send "Screen recording" "Started on $mon"
      wf-recorder -o "$mon" -f "$out"
    '';
  };

  services.swayosd.enable = true;

  # ── USB automount (thunar-volman only works while Thunar is running) ───
  services.udiskie = {
    enable = true;
    tray = "auto";
  };
}
