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
│   ├── server/                        # Headless — nginx, fail2ban, auto-update
│   └── dns/                           # Shared profile for every DNS node
│       ├── nodes.nix                  # Fleet registry: anycast IP, BGP, per-node facts
│       ├── default.nix                # Profile: networking, staggered GitOps upgrades
│       ├── adguard.nix                # DNS policy: upstreams, filters, rewrites
│       └── <node>/hardware-configuration.nix
│
├── modules/
│   ├── nixos/                         # System-level toggle modules
│   │   ├── hyprland.nix               # mkEnableOption for Hyprland
│   │   ├── audio.nix                  # PipeWire support packages
│   │   ├── bluetooth.nix              # BlueZ + Blueman
│   │   ├── docker.nix                 # Docker + Podman + lazydocker
│   │   ├── anycast-dns.nix            # AdGuard Home + BIRD anycast + health loop
│   │   └── gaming.nix                 # Steam + gamescope + gamemode
│   └── home/                          # Home-Manager dotfiles
│       ├── shell/                     # Zsh + oh-my-zsh + Starship (Catppuccin)
│       │   ├── default.nix            # Zsh config, direnv, fzf
│       │   ├── aliases.nix            # Git, k8s, Docker, Nix, modern CLI
│       │   └── starship.nix           # Elaborate Catppuccin Mocha prompt
│       ├── git.nix                    # Git + delta + lazygit + gh + jj + SSH signing
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

## Adding a DNS node

All DNS nodes share one configuration; they differ only in `hosts/dns/nodes.nix`.
Nodes take their LAN address from DHCP and the router accepts dynamic BGP peers
from the whole subnet, so **the router side never changes** — `just mikrotik-dns`
is one-time setup, not a per-node step.

1. Add an entry to `nodes` in `hosts/dns/nodes.nix` (`system`, `interface`, `stateVersion`)
2. Add `hosts/dns/<name>/hardware-configuration.nix`
3. First install: find the node's lease on the router (`/ip dhcp-server lease print`),
   then `just deploy <name> ferro@<lease>` — `system.autoUpgrade` keeps it in sync
   with `main` afterwards

Clients query the fleet on the anycast address (`site.anycastAddress`), never a
node's own address. To debug a specific node: `ssh` in and `dig @10.53.53.53`.

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
