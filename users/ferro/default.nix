{ pkgs, lib, config, inputs, isDesktop, hostname, ... }:

{
  imports = [
    # ── Shared modules ────────────────────────────────────────────────
    ../../modules/home/shell
    ../../modules/home/git.nix
    ../../modules/home/halloy.nix
    ../../modules/home/neovim.nix
    ../../modules/home/spotify-player.nix
    ../../modules/home/terminal.nix
  ]
  ++ lib.optionals isDesktop [
    ../../modules/home/desktop
  ];

  # ── Home directory ──────────────────────────────────────────────────────
  home = {
    username = "ferro";
    homeDirectory = "/home/ferro";
    stateVersion = "25.11";
  };

  # ── Neovim ──────────────────────────────────────────────────────────────
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
  };

  # ── Yazi (TUI file manager) ─────────────────────────────────────────────
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  # ── OpenCode (AI coding assistant) ──────────────────────────────────────
  programs.opencode = {
    enable = true;
    settings = {
      autoshare = false;
      autoupdate = true;
      plugin = [ "@ex-machina/opencode-anthropic-auth" ];
    };
  };

  # ── SSH config ──────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "gitlab.com" = {
        HostName = "gitlab.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "server" = {
        HostName = "server.tail0000.ts.net"; # Replace with your Tailscale hostname
        User = "ferro";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };



  # ── Packages ────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # ── Dev tools ─────────────────────────────────────────────────────
    just
    cargo-watch
    cargo-edit
    cargo-nextest
    cargo-audit
    cargo-flamegraph
    tokei
    hyperfine

    # ── Kubernetes / DevOps ───────────────────────────────────────────
    kubectl
    kubernetes-helm
    kubectx
    kustomize
    fluxcd
    argocd
    terraform
    awscli2

    # ── Modern CLI ────────────────────────────────────────────────────
    curl
    wget
    ripgrep
    fd
    sd
    dust
    duf
    bottom
    fzf
    jq
    yq-go
    xh

    # ── System ────────────────────────────────────────────────────────
    fastfetch
    nix-tree
    nix-output-monitor
    nvd
    tealdeer
    ouch
  ] ++ lib.optionals isDesktop [
    # ── Desktop apps ──────────────────────────────────────────────────
    # ghostty is provided by programs.ghostty (pinned to unstable in terminal.nix)
    kitty
    discord
    brightnessctl
    vlc
  ];

  # ── XDG directories ────────────────────────────────────────────────────
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = false;
    };
    mimeApps = lib.mkIf isDesktop {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
      };
    };
  };

  # ── Firefox ─────────────────────────────────────────────────────────────
  programs.firefox = lib.mkIf isDesktop {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles.ferro = {
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "dom.security.https_only_mode" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      };
      search = {
        default = "ddg";
        force = true;
      };
      extensions = {
        force = true;
        packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          bitwarden
          sponsorblock
          return-youtube-dislikes
        ];
      };
    };
  };
  catppuccin.firefox = lib.mkIf isDesktop {
    profiles.ferro.enable = true;
  };

  # ── OBS Studio ──────────────────────────────────────────────────────────
  programs.obs-studio.enable = lib.mkIf isDesktop true;

  # ── Zed ────────────────────────────────────────────────────────────────
  programs.zed-editor.enable = lib.mkIf isDesktop true;

  # ── Zathura (PDF viewer) ───────────────────────────────────────────────
  programs.zathura.enable = lib.mkIf isDesktop true;

  # ── Imv (image viewer) ─────────────────────────────────────────────────
  programs.imv.enable = lib.mkIf isDesktop true;

  programs.home-manager.enable = true;
}
