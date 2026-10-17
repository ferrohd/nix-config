{ inputs }:

let
  inherit (inputs.nixpkgs) lib;

  # ── mkHost ──────────────────────────────────────────────────────────────
  # Build a full NixOS + Home-Manager configuration for a host.
  #
  # Args:
  #   hostname     : string     — the machine's name
  #   profile      : string     — maps to hosts/<profile>/ (defaults to hostname;
  #                               lets several machines share one host profile)
  #   system       : string     — e.g. "x86_64-linux"
  #   users        : [ string ] — list of usernames (from users/<name>/)
  #   desktop      : bool       — enables GUI modules when true
  #   secureBoot   : bool       — enables lanzaboote Secure Boot
  #   extraModules : [ module ] — hardware-specific or one-off modules
  #
  mkHost =
    { hostname
    , profile ? hostname
    , system ? "x86_64-linux"
    , users ? [ ]
    , desktop ? true
    , secureBoot ? false
    , extraModules ? [ ]
    ,
    }:
    let
      # Shared specialArgs available in every NixOS + HM module
      specialArgs = {
        inherit inputs hostname;
        flake = inputs.self;
        isDesktop = desktop;
      };

      # Single source of truth for theming — change flavor/accent here
      catppuccinDefaults = { catppuccin = { enable = true; flavor = "mocha"; accent = "mauve"; }; };
    in
    lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        # ── Host-specific config ──────────────────────────────────────
        ../hosts/${profile}

        # ── Shared system modules (locale, networking, security…) ─────
        ../hosts/common

        # ── Containers ────────────────────────────────────────────────
        ../modules/nixos/docker.nix

        # ── Secrets ───────────────────────────────────────────────────
        inputs.sops-nix.nixosModules.sops

        # ── Theming ───────────────────────────────────────────────────
        inputs.catppuccin.nixosModules.catppuccin
        catppuccinDefaults
      ]
      # ── Secure Boot (opt-in per host) ─────────────────────────────────
      ++ lib.optionals secureBoot [
        inputs.lanzaboote.nixosModules.lanzaboote
        ../modules/nixos/secure-boot.nix
      ]
      # ── Desktop / GUI modules ─────────────────────────────────────────
      ++ lib.optionals desktop [
        ../modules/nixos/hyprland.nix
        ../modules/nixos/audio.nix
        ../modules/nixos/bluetooth.nix
        ../modules/nixos/filemanager.nix
        ../modules/nixos/gaming.nix
        # Imported everywhere, but stays off until a host opts in with
        # myconfig.sunshine.enable (unlike hyprland below).
        ../modules/nixos/sunshine.nix
        { myconfig.hyprland.enable = true; boot.plymouth.enable = true; }
      ]
      # ── Home-Manager integration ──────────────────────────────────────
      ++ [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            extraSpecialArgs = specialArgs;
            sharedModules = [
              inputs.catppuccin.homeModules.catppuccin
              catppuccinDefaults
            ];
            users = lib.genAttrs users (user: import ../users/${user});
          };
        }
      ]
      # ── User system-level accounts ────────────────────────────────────
      ++ map (user: ../users/${user}/system.nix) users
      # ── Extra per-host modules (hardware, etc.) ───────────────────────
      ++ extraModules;
    };
in
{
  inherit mkHost;

  # ── mkDnsHosts ──────────────────────────────────────────────────────────
  # One nixosConfiguration per entry in hosts/dns/nodes.nix, all built from
  # the shared hosts/dns profile. Only the hardware config is per machine.
  #
  # Args:
  #   users : [ string ] — accounts to create on every DNS node
  #
  mkDnsHosts = { users ? [ ] }:
    lib.mapAttrs
      (name: node: mkHost {
        hostname = name;
        profile = "dns";
        inherit (node) system;
        inherit users;
        desktop = false;
        extraModules = [ ../hosts/dns/${name}/hardware-configuration.nix ];
      })
      (import ../hosts/dns/nodes.nix).nodes;
}
