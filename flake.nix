{
  description = "ferro's NixOS infrastructure — multi-host, reproducible, flake-native";



  inputs = {
    # ── Core ────────────────────────────────────────────────────────────
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ── Flake infrastructure ────────────────────────────────────────────
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";

    # ── Home Manager ────────────────────────────────────────────────────
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Hardware quirks ─────────────────────────────────────────────────
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # ── Theming ─────────────────────────────────────────────────────────
    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    opencode.url = "github:anomalyco/opencode";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    let
      inherit (import ./lib { inherit inputs; }) mkHost;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # ── Per-system outputs ────────────────────────────────────────────
      perSystem = { pkgs, ... }: {
        # Development shell for working on this repo
        devShells.default = pkgs.mkShell {
          name = "nixos-config";
          packages = with pkgs; [
            nil # Nix LSP
            nixpkgs-fmt # Formatter
            statix # Nix linter
            deadnix # Dead code finder
            sops # Secrets editor
            age # Encryption
            ssh-to-age # Convert SSH keys → age
            just # Command runner
          ];
        };

        # Formatter for `nix fmt`
        formatter = pkgs.nixpkgs-fmt;

        # CI checks
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
      };
    };
}
