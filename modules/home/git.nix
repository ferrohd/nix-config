_:

{
  # ── Git ──────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;

    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Alessandro Ferrara";
        email = "aleferrara1998@gmail.com";
      };
      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status -sb";
        lg = "log --oneline --graph --decorate --all -20";
        wip = "!git add -A && git commit -m 'WIP: checkpoint'";
        undo = "reset --soft HEAD~1";
        amend = "commit --amend --no-edit";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      merge.conflictstyle = "zdiff3";
      diff.algorithm = "histogram";
      rerere.enabled = true; # Remember conflict resolutions
      column.ui = "auto";
      branch.sort = "-committerdate";
      gpg.format = "ssh"; # Sign commits with SSH key
      core = {
        autocrlf = "input";
        pager = "delta";
      };
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };

    ignores = [
      # OS
      ".DS_Store"

      # Editors
      ".idea/"
      ".vscode/"
      "*.swp"
      "*~"

      # Nix
      "result"
      "result-*"

      # Environment
      ".direnv/"
      ".envrc.local"
    ];
  };

  # ── Delta (beautiful diffs) ──────────────────────────────────────────────
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = false;
      syntax-theme = "Catppuccin Mocha";
      dark = true;
    };
  };

  # ── GitHub CLI ──────────────────────────────────────────────────────────
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # ── Lazygit (TUI git client) ────────────────────────────────────────────
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
        nerdFontsVersion = "3";
        theme.lightTheme = false;
      };
      git.paging = {
        colorArg = "always";
        pager = "delta --paging=never";
      };
    };
  };
}
