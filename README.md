# ferro's NixOS Infrastructure

100% reproducible, declarative NixOS configurations. Flake-native, multi-host, single-user (extensible to multi-user).

## Architecture

```
.
├── flake.nix                          # Entry point — inputs, hosts, overlays
├── lib/default.nix                    # mkHost factory function
│
├── hosts/
│   ├── common/                        # Shared across all hosts
│   │   ├── default.nix                # Boot, shell, unfree, env vars
│   │   ├── nix-settings.nix           # Flakes, caches, GC, latest nix
│   │   ├── locale.nix                 # Europe/Rome, it_IT, Italian keyboard
│   │   ├── networking.nix             # Firewall, SSH hardening, DNS, Tailscale
│   │   ├── security.nix              # Kernel sysctl, polkit, sudo
│   │   └── fonts.nix                  # JetBrainsMono NF, Inter, Noto
│   ├── blackmesa/                     # AMD/Nvidia workstation, dual 4K, gaming
│   ├── laptop/                        # Portable — auto-cpufreq, lid switch
│   └── server/                        # Headless — nginx, fail2ban, auto-update
│
├── modules/
│   ├── nixos/                         # System-level toggle modules
│   │   ├── hyprland.nix               # mkEnableOption for Hyprland
│   │   ├── audio.nix                  # PipeWire support packages
│   │   ├── bluetooth.nix              # BlueZ + Blueman
│   │   ├── docker.nix                 # Docker + Podman + lazydocker
│   │   └── gaming.nix                 # Steam + gamescope + gamemode
│   └── home/                          # Home-Manager dotfiles
│       ├── shell/                     # Zsh + oh-my-zsh + Starship (Catppuccin)
│       │   ├── default.nix            # Zsh config, direnv, fzf
│       │   ├── aliases.nix            # Git, k8s, Docker, Nix, modern CLI
│       │   └── starship.nix           # Elaborate Catppuccin Mocha prompt
│       ├── git.nix                    # Git + delta + lazygit + gh + SSH signing
│       ├── neovim.nix                 # Full IDE: LSP, Telescope, Treesitter, cmp
│       ├── terminal.nix               # Kitty + Tmux (Catppuccin)
│       └── desktop/                   # Hyprland + desktop environment
│           ├── default.nix            # Hyprland config, keybinds, window rules
│           ├── waybar/                # Floating bar + Catppuccin CSS
│           ├── dunst.nix              # Notification daemon
│           ├── rofi.nix               # App launcher (rofi-wayland + calc)
│           ├── hyprlock.nix           # Lock screen
│           ├── hypridle.nix           # Idle management (lock → dpms → suspend)
│           └── extras.nix             # grimblast, cliphist, swayosd, hyprpaper
│
├── users/ferro/                       # ferro's config
│   ├── system.nix                     # OS account, groups, SSH keys
│   └── default.nix                    # HM config, per-host monitors, dev tools
│
├── overlays/default.nix               # OpenCode + custom overlays
├── secrets/                           # sops-nix encrypted secrets
├── .sops.yaml                         # Age key → host mapping
├── justfile                           # Command runner
└── .github/workflows/ci.yml           # Lint + build all hosts
```

## Quick start

```bash
git clone <this-repo> ~/.config/nixos
cd ~/.config/nixos
just switch blackmesa
```

## Daily commands

```
just switch          # Rebuild current host (auto-detects hostname)
just test            # Test build (auto-rollback on failure)
just diff            # Build and show what changed
just update          # Update all flake inputs
just gc              # Garbage-collect old generations
just ci              # Run full lint + format + check locally
just deploy server user@10.0.0.5   # Remote deploy via SSH
```

## Adding a new host

1. Create `hosts/<name>/default.nix` + `hardware-configuration.nix`
2. Add to `flake.nix` → `nixosConfigurations`
3. `just switch <name>`

## Adding a new user

1. Create `users/<name>/system.nix` + `users/<name>/default.nix`
2. Add `"<name>"` to the host's `users` list in `flake.nix`
3. Rebuild

## Secrets

```bash
# One-time setup
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt  # put this in .sops.yaml

# Edit secrets
just secrets-common
just secrets blackmesa
```

## What was fixed from the draft config

- `rofi` → `rofi-wayland` (X11 rofi doesn't work properly under Hyprland)
- Added missing user groups: `docker`, `video`, `audio`, `input`, `render`
- Added nix GC, store optimisation, binary cache config
- Added firewall with sane defaults
- Added SSH hardening (key-only, no root, max 3 attempts)
- Added kernel sysctl hardening
- Added Docker + Podman with auto-prune
- Added sops-nix secrets management
- Added SSH client config with GitHub/GitLab blocks
- Added direnv + nix-direnv for per-project shells
- Added delta for beautiful git diffs
- Added Git SSH commit signing
- Added tmux with Catppuccin + vim-navigator
- Structured for multi-host (laptop, server) with `isDesktop` toggle
