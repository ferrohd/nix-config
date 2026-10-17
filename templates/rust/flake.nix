{
  description = "Rust project — pinned toolchain via rust-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem = { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ (import inputs.rust-overlay) ];
          };

          toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

          # Platforms compiled for but never run, checked by `just targets`. This list must be
          # complete: the override *replaces* rust-toolchain.toml's `targets` rather than
          # extending it.
          #
          # Worth adding: "x86_64-pc-windows-msvc" if you ship a Windows binary — `cargo check`
          # catches the #[cfg(unix)] E0599 class that testing on Linux never will.
          # "thumbv7em-none-eabi" proves a crate is genuinely sans-IO and allocation free.
          crossTargets = [
            "aarch64-apple-darwin"
            "aarch64-unknown-linux-gnu"
          ];

          # Derived so `devShells.msrv` is an actual compiler of that version, rather than an env
          # var pointed at a different one. `.0` because rust-version is a two-component floor
          # and rust-overlay keys on full releases. Keep clippy.toml's `msrv` in step.
          msrv = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).workspace.package.rust-version;

          # What the check recipes need, and so what CI needs. Separate from devTools because CI
          # enters this shell once per job and the editor tooling is where the weight is:
          # release-plz 415 MiB, rust-analyzer 141 MiB, mold 109 MiB. Nothing here exceeds 26 MiB.
          checkTools = with pkgs; [
            just
            cargo-nextest
            cargo-hack
            cargo-deny
            cargo-dist
            # Not in `just all` — needs a published version to compare against. Here because
            # release-plz shells out to it to decide version bumps.
            cargo-semver-checks
            cargo-machete
            actionlint
            taplo
            typos
            yq-go
            git
          ];

          # Only useful to a human: watching, snapshots, previewing a release.
          devTools = with pkgs; [
            cargo-insta
            bacon
            cargo-outdated
            cargo-edit
            cargo-flamegraph
            # 415 MiB, and the reason this list exists. Only `just release-check` uses it; CI
            # gets release-plz from its action.
            release-plz
          ];
        in
        {
          devShells = {
            # A superset of `ci`, so `just all` works straight from direnv.
            default = pkgs.mkShell {
              packages = [
                # rust-src lets rust-analyzer resolve `std`. An extension here rather than in
                # rust-toolchain.toml so CI does not download it.
                (toolchain.override {
                  targets = crossTargets;
                  extensions = [ "rust-src" ];
                })
              ]
              ++ (with pkgs; [
                # Pinned to this toolchain, so it beats any rust-analyzer further down PATH.
                rust-analyzer
                mold
              ])
              ++ checkTools
              ++ devTools;

              # Not set in `ci`: RUSTFLAGS is one string, so occupying it forces every caller to
              # append rather than assign. On nightly, `-Zthreads=8` and `-Zmacro-backtrace` are
              # worth appending.
              RUSTFLAGS = "-C link-arg=-fuse-ld=mold";

              # No pkg-config/openssl until a build script needs them; rustls avoids the question.
            };

            # What CI enters.
            ci = pkgs.mkShell {
              packages = [ (toolchain.override { targets = crossTargets; }) ] ++ checkTools;

              # `nix develop` inherits any variable it does not set, so entering this from a
              # direnv-activated `default` drags RUSTFLAGS in. mold leaks via PATH too, so
              # without this the failure only shows on a machine with the flag but not the linker.
              shellHook = "unset RUSTFLAGS";
            };

            # One recipe's worth. `minimal` suffices: checking needs neither clippy nor rustfmt.
            msrv = pkgs.mkShell {
              packages = [ pkgs.rust-bin.stable."${msrv}.0".minimal pkgs.just ];
              shellHook = "unset RUSTFLAGS";
            };
          };

          formatter = pkgs.nixpkgs-fmt;
        };
    };
}
