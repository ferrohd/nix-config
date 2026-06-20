{ config, ... }:

{
  imports = [
    ./aliases.nix
    ./starship.nix
  ];

  # ── Zsh ─────────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "rust"
        "colored-man-pages"
        "kubectl"
        "helm"
        "kubectx"
        "fluxcd"
        "sudo"
        "extract"
        "docker"
        "docker-compose"
      ];
    };

    initContent = ''
      # Completions not covered by OMZ plugins
      source <(kustomize completion zsh 2>/dev/null)
      source <(argocd completion zsh 2>/dev/null)
      source <(k9s completion zsh 2>/dev/null)
    '';
  };

  programs.starship.enableZshIntegration = true;

  # ── Zoxide (fast directory switching) ───────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── Direnv (per-directory environments) ─────────────────────────────────
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.warn_timeout = "30s";
  };

  # ── CLI tools ────────────────────────────────────────────────────────────
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.eza.enable = true;
  programs.k9s.enable = true;

  # ── FZF ─────────────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [ "--height=40%" "--layout=reverse" "--border" ];
  };

  # ── Atuin (shell history with fuzzy search) ──────────────────────────────
  # Catppuccin theme (catppuccin-mocha-mauve) is auto-applied via the global
  # catppuccin module. Atuin binds Ctrl-R and the Up arrow (local-only; no sync).
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      style = "compact";
      inline_height = 20;
      show_preview = true;
      update_check = false; # NixOS manages the version
    };
  };
}
