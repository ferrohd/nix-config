_:

# Catppuccin Mocha palette:
# base:    #1e1e2e  surface0: #313244  overlay0: #6c7086
# text:    #cdd6f4  subtext1: #bac2de  subtext0: #a6adc8
# mauve:   #cba6f7  blue:     #89b4fa  sapphire: #74c7ec
# sky:     #89dceb  teal:     #94e2d5  green:    #a6e3a1
# yellow:  #f9e2af  peach:    #fab387  red:      #f38ba8
# flamingo:#f2cdcd  lavender: #b4befe

{
  programs.starship = {
    enable = true;

    settings = {
      format = ''
        $username$hostname$directory$git_branch$git_status$kubernetes$helm$terraform$rust$python$nodejs$golang$java$fill$cmd_duration$time
        $character'';

      add_newline = true;

      # ── Prompt character ───────────────────────────────────────────────
      character = {
        success_symbol = "[❯](bold #cba6f7)";
        error_symbol   = "[❯](bold #f38ba8)";
        vimcmd_symbol  = "[❮](bold #a6e3a1)";
      };

      # ── OS / user / host ───────────────────────────────────────────────
      os.disabled = true;

      username = {
        show_always = false;
        style_user  = "bg:#313244 fg:#cdd6f4 bold";
        style_root  = "bg:#313244 fg:#f38ba8 bold";
        format      = "[ $user ]($style)";
      };

      hostname = {
        ssh_only = true;
        style    = "bg:#313244 fg:#89b4fa bold";
        format   = "[@$hostname ]($style)";
      };

      # ── Directory ──────────────────────────────────────────────────────
      directory = {
        style              = "bold #89b4fa";
        read_only_style    = "#f38ba8";
        truncation_length  = 4;
        truncate_to_repo   = true;
        read_only          = " 󰌾";
        format             = "[ 󰉋 $path]($style)[$read_only]($read_only_style) ";
        substitutions = {
          "~" = "󰋜 ";
        };
      };

      # ── Git ────────────────────────────────────────────────────────────
      git_branch = {
        style    = "bold #cba6f7";
        symbol   = " ";
        format   = "[$symbol$branch(:$remote_branch)]($style) ";
      };

      git_status = {
        style     = "#f9e2af";
        format    = "([$all_status$ahead_behind]($style) )";
        conflicted = "󰩌 ";
        ahead      = "⇡$count ";
        behind     = "⇣$count ";
        diverged   = "⇕⇡$ahead_count⇣$behind_count ";
        untracked  = "? ";
        stashed    = "󰏗 ";
        modified   = "! ";
        staged     = "+ ";
        renamed    = "» ";
        deleted    = "✘ ";
      };

      # ── Kubernetes ────────────────────────────────────────────────────
      kubernetes = {
        disabled = false;
        style    = "bold #94e2d5";
        symbol   = "󱃾 ";
        format   = "[$symbol$context( \\($namespace\\))]($style) ";
        contexts = [
          {
            context_pattern = ".*";
            style           = "bold #94e2d5";
          }
        ];
      };

      helm = {
        disabled = false;
        style    = "#89dceb";
        symbol   = "⎈ ";
        format   = "[$symbol($version)]($style) ";
      };

      terraform = {
        disabled = false;
        style    = "#b4befe";
        symbol   = "󱁢 ";
        format   = "[$symbol($version)]($style) ";
      };

      # ── Languages (show only when relevant) ───────────────────────────
      rust = {
        style  = "bold #fab387";
        symbol = " ";
        format = "[$symbol($version)]($style) ";
      };

      python = {
        style          = "#f9e2af";
        symbol         = " ";
        format         = "[$symbol($version)(\\($virtualenv\\))]($style) ";
        python_binary  = [ "python3" "python" ];
      };

      nodejs = {
        style  = "#a6e3a1";
        symbol = " ";
        format = "[$symbol($version)]($style) ";
      };

      golang = {
        style  = "#89dceb";
        symbol = " ";
        format = "[$symbol($version)]($style) ";
      };

      java = {
        style  = "#f38ba8";
        symbol = " ";
        format = "[$symbol($version)]($style) ";
      };

      # ── Right side fill + meta ─────────────────────────────────────────
      fill = {
        symbol = " ";
      };

      cmd_duration = {
        min_time        = 2000;
        style           = "#a6adc8";
        show_milliseconds = false;
        format          = "[ 󱎫 $duration]($style) ";
      };

      time = {
        disabled  = false;
        style     = "#6c7086";
        format    = "[ $time]($style)";
        time_format = "%H:%M";
      };

      # ── Disabled clutter ──────────────────────────────────────────────
      package.disabled  = true;
      docker_context.disabled = true;
    };
  };
}
