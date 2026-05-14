# justfile — run with `just <recipe>`

# Default recipe: show help
default:
    @just --list

# ── Build & Switch ────────────────────────────────────────────────────────

# Rebuild and switch to the new configuration
switch hostname=`hostname`:
    sudo nixos-rebuild switch --flake .#{{hostname}}

# Rebuild and activate on next boot
boot hostname=`hostname`:
    sudo nixos-rebuild boot --flake .#{{hostname}}

# Test build without switching (rollback on failure)
test hostname=`hostname`:
    sudo nixos-rebuild test --flake .#{{hostname}}

# Build without activating (dry run)
build hostname=`hostname`:
    nixos-rebuild build --flake .#{{hostname}}

# Build and show what changed
diff hostname=`hostname`:
    nixos-rebuild build --flake .#{{hostname}} && nvd diff /run/current-system result

# ── Flake ─────────────────────────────────────────────────────────────────

# Update all flake inputs
update:
    nix flake update

# Update a specific input
update-input input:
    nix flake update {{input}}

# Check flake for errors
check:
    nix flake check

# Show flake outputs
show:
    nix flake show

# ── Maintenance ───────────────────────────────────────────────────────────

# Garbage-collect old generations
gc:
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Garbage-collect generations older than N days
gc-older days="7":
    sudo nix-collect-garbage --delete-older-than {{days}}d
    nix-collect-garbage --delete-older-than {{days}}d

# Optimise the Nix store
optimise:
    sudo nix store optimise

# List system generations
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# ── Code quality ──────────────────────────────────────────────────────────

# Format all Nix files
fmt:
    find . -name '*.nix' | xargs nixpkgs-fmt

# Lint with statix
lint:
    statix check --config statix.toml .

# Find dead code
deadcode:
    deadnix .

# Fix auto-fixable issues
fix:
    statix fix .
    deadnix -e .

# Run all checks
ci: fmt lint deadcode check

# ── Secrets ───────────────────────────────────────────────────────────────

# Edit common secrets
secrets-common:
    sops secrets/common.yaml

# Edit host-specific secrets
secrets host:
    sops secrets/{{host}}.yaml

# ── Remote deploy ─────────────────────────────────────────────────────────

# Deploy to a remote host via SSH
deploy host target:
    nixos-rebuild switch --flake .#{{host}} --target-host {{target}} --use-remote-sudo

# ── Dev ───────────────────────────────────────────────────────────────────

# Enter the dev shell
shell:
    nix develop

# Open a REPL with flake context
repl:
    nix repl --expr 'builtins.getFlake (toString ./.)'
