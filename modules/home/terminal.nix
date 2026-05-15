{ pkgs, lib, ... }:

{
  # ── Ghostty (primary terminal) ──────────────────────────────────────────
  programs.ghostty = {
    enable = true;
    package = pkgs.unstable.ghostty;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 14;
      #theme = "catppuccin-mocha";
      theme = "stylix";
      background-opacity = 0.85;
      background-blur-radius = 20;
      cursor-style = "bar";
      cursor-style-blink = true;
      window-padding-x = 8;
      window-padding-y = 8;
      window-decoration = "server"; # let Hyprland draw the border
      scrollback-limit = 10000;
      audio-bell = false;
      confirm-close-surface = false;
      shell-integration = "zsh";
    };
  };

  # ── Kitty (secondary terminal) ──────────────────────────────────────────
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 14;
      window_padding_width = 8;
      hide_window_decorations = "titlebar-only";
      confirm_os_window_close = 0;
      background_opacity = lib.mkForce "0.85";
      enable_audio_bell = "no";
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";
      wayland_titlebar_color = "system";
      linux_display_server = "wayland";
      scrollback_lines = 10000;
    };
  };

  # ── Tmux ────────────────────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    mouse = true;
    keyMode = "vi";

    extraConfig = ''
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g renumber-windows on

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
      set -g status-position top
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      resurrect
      continuum
      catppuccin
    ];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
