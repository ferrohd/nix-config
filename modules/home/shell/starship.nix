_:

{
  programs.starship = {
    enable = true;

    settings = {
      format = ''$all'';

      add_newline = true;

      # ── Prompt character ───────────────────────────────────────────────
      character = {
        success_symbol = "[❯](bold mauve)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      # ── OS / user / host ───────────────────────────────────────────────
      os.disabled = true;

      username = {
        show_always = false;
        style_user = "bg:surface0 fg:text bold";
        style_root = "bg:surface0 fg:red bold";
        format = "[ $user ]($style)";
      };

      hostname = {
        ssh_only = true;
        style = "bg:surface0 fg:blue bold";
        format = "[@$hostname ]($style)";
      };

      # ── Directory ──────────────────────────────────────────────────────
      directory = {
        style = "bold blue";
        read_only_style = "red";
        truncation_length = 4;
        truncate_to_repo = true;
        read_only = " 󰌾";
        format = "[ 󰉋 $path]($style)[$read_only]($read_only_style) ";
        substitutions = {
          "~" = "󰋜 ";
        };
      };

      # ── Git ────────────────────────────────────────────────────────────
      git_branch = {
        style = "bold mauve";
        symbol = "󰘬 ";
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };

      git_status = {
        style = "yellow";
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = "󰩌 ";
        ahead = "⇡$count ";
        behind = "⇣$count ";
        diverged = "⇕⇡$ahead_count⇣$behind_count ";
        untracked = "? ";
        stashed = "󰏗 ";
        modified = "! ";
        staged = "+ ";
        renamed = "» ";
        deleted = "✘ ";
      };

      # ── Kubernetes ────────────────────────────────────────────────────
      kubernetes = {
        disabled = false;
        style = "bold teal";
        symbol = "󱃾 ";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
        contexts = [
          {
            context_pattern = ".*";
            style = "bold teal";
          }
        ];
      };

      helm = {
        disabled = false;
        style = "sky";
        symbol = "󱍳 ";
        format = "[$symbol($version)]($style) ";
      };

      terraform = {
        disabled = false;
        style = "lavender";
        symbol = "󱁢 ";
        format = "[$symbol($version)]($style) ";
      };

      # ── Languages (show only when relevant) ───────────────────────────
      rust = {
        style = "bold peach";
        symbol = " ";
        format = "[$symbol($version)]($style) ";
      };

      python = {
        style = "yellow";
        symbol = " ";
        format = "[$symbol($version)(\\($virtualenv\\))]($style) ";
        python_binary = [ "python3" "python" ];
      };

      nodejs = {
        style = "green";
        symbol = "󰎙 ";
        format = "[$symbol($version)]($style) ";
      };

      golang = {
        style = "sky";
        symbol = " ";
        format = "[$symbol($version)]($style) ";
      };

      java = {
        style = "red";
        symbol = " ";
        format = "[$symbol($version)]($style) ";
      };

      # ── Right side fill + meta ─────────────────────────────────────────
      fill = {
        symbol = " ";
      };

      cmd_duration = {
        min_time = 2000;
        style = "subtext0";
        show_milliseconds = false;
        format = "[ 󱎫 $duration]($style) ";
      };

      time = {
        disabled = false;
        style = "overlay0";
        format = "[ $time]($style)";
        time_format = "%H:%M";
      };

      # ── Disabled clutter ──────────────────────────────────────────────
      package.disabled = true;
      docker_context.disabled = true;
    };
  };
}
