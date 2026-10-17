{
  description = "ferro's NixOS infrastructure — multi-host, reproducible, flake-native";



  inputs = {
    # ── Core ────────────────────────────────────────────────────────────
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ── Flake infrastructure ────────────────────────────────────────────
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";

    # ── Home Manager ────────────────────────────────────────────────────
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Hardware quirks ─────────────────────────────────────────────────
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # ── Theming ─────────────────────────────────────────────────────────
    catppuccin.url = "github:catppuccin/nix/release-26.05";

    # ── Secrets management ──────────────────────────────────────────────
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Declarative disk layout ─────────────────────────────────────────
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Secure Boot ─────────────────────────────────────────────────────
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Firefox addons ──────────────────────────────────────────────────
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Dev tools ───────────────────────────────────────────────────────
    opencode.url = "github:anomalyco/opencode/350c726aa8b6b11eb9242040bc5eb7ae837fbf8a";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    let
      inherit (import ./lib { inherit inputs; }) mkHost;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # ── Per-system outputs ────────────────────────────────────────────
      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          name = "nixos-config";
          packages = with pkgs; [
            nil
            nixpkgs-fmt
            statix
            deadnix
            sops
            age
            ssh-to-age
            just
          ];
        };

        formatter = pkgs.nixpkgs-fmt;

        checks = {
          lint = pkgs.runCommand "lint" { buildInputs = [ pkgs.statix pkgs.deadnix ]; } ''
            cd ${self}
            statix check .
            deadnix --fail .
            touch $out
          '';
        };
      };

      # ── Host configurations ───────────────────────────────────────────
      flake = {
        nixosConfigurations = {
          blackmesa = mkHost {
            hostname = "blackmesa";
            system = "x86_64-linux";
            users = [ "ferro" ];
            desktop = true;
            extraModules = [
              inputs.nixos-hardware.nixosModules.common-cpu-amd
              inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
              ./hosts/blackmesa/home.nix
            ];
          };

          laptop = mkHost {
            hostname = "laptop";
            system = "x86_64-linux";
            users = [ "ferro" ];
            desktop = true;
            extraModules = [
              ./hosts/laptop/home.nix
            ];
          };

          server = mkHost {
            hostname = "server";
            system = "x86_64-linux";
            users = [ "ferro" ];
            desktop = false;
            extraModules = [ ];
          };
        };

        # ── Overlays ────────────────────────────────────────────────────
        overlays.default = import ./overlays { inherit (inputs) opencode nixpkgs-unstable; };

        # ── Project templates ───────────────────────────────────────────
        # Scaffold with: nix flake init -t ~/.config/nixos#rust
        #
        # A cargo workspace: toolchain pinned by rust-toolchain.toml, three dev shells
        # (default / ci / msrv), the check suite behind `just`, and the release pipeline wired
        # up. `just all` is green on a fresh scaffold; start with the justfile, which lists the
        # few setup steps only you can do. For nightly, flip `channel` in rust-toolchain.toml.
        templates = {
          rust = {
            path = ./templates/rust;
            description = "Rust workspace — pinned toolchain, full check suite, release pipeline";
          };
          default = self.templates.rust;
        };
      };
    };
}
