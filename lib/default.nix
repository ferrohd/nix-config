{ inputs }:

let
  inherit (inputs.nixpkgs) lib;
in
{
  # ── mkHost ──────────────────────────────────────────────────────────────
  # Build a full NixOS + Home-Manager configuration for a host.
  #
  # Args:
  #   hostname     : string     — maps to hosts/<hostname>/
  #   system       : string     — e.g. "x86_64-linux"
  #   users        : [ string ] — list of usernames (from users/<name>/)
  #   desktop      : bool       — enables GUI modules when true
  #   secureBoot   : bool       — enables lanzaboote Secure Boot
  #   extraModules : [ module ] — hardware-specific or one-off modules
  #
  mkHost = {
    hostname,
    system ? "x86_64-linux",
    users ? [ ],
    desktop ? true,
    secureBoot ? false,
    extraModules ? [ ],
  }:
    let
      # Shared specialArgs available in every NixOS + HM module
      specialArgs = {
        inherit inputs hostname;
        flake = inputs.self;
        isDesktop = desktop;
      };
    in
    lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        # ── Host-specific config ──────────────────────────────────────
        ../hosts/${hostname}

        # ── Shared system modules (locale, networking, security…) ─────
        ../hosts/common

        # ── Containers ────────────────────────────────────────────────
        ../modules/nixos/docker.nix

        # ── Secrets ───────────────────────────────────────────────────
        inputs.sops-nix.nixosModules.sops

        # ── Theming ───────────────────────────────────────────────────
      ]
      # ── Secure Boot (opt-in per host) ─────────────────────────────────
      ++ lib.optionals secureBoot [
        inputs.lanzaboote.nixosModules.lanzaboote
        ../modules/nixos/secure-boot.nix
      ]
      # ── Desktop / GUI modules ─────────────────────────────────────────
      ++ lib.optionals desktop [
        inputs.stylix.nixosModules.stylix
        ../modules/nixos/hyprland.nix
        ../modules/nixos/audio.nix
        ../modules/nixos/bluetooth.nix
        ../modules/nixos/gaming.nix
        { myconfig.hyprland.enable = true; }
      ]
      # ── Home-Manager integration ──────────────────────────────────────
      ++ [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            users = lib.genAttrs users (user: import ../users/${user});
          };
        }
      ]
      # ── User system-level accounts ────────────────────────────────────
      ++ map (user: ../users/${user}/system.nix) users
      # ── Extra per-host modules (hardware, etc.) ───────────────────────
      ++ extraModules;
    };
}
