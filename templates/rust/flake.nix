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

          # Single source of truth for the toolchain: rust-toolchain.toml.
          # `cargo`, `rustc`, `clippy`, `rustfmt`, `rust-src` and
          # `rust-analyzer` all come from here, so they always match.
          toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        in
        {
          devShells.default = pkgs.mkShell {
            packages = [
              toolchain
            ] ++ (with pkgs; [
              # Common native build deps for crates like openssl-sys
              pkg-config
              openssl

              # Fast linker
              mold
            ]);

            # Link with mold instead of the default bfd linker
            RUSTFLAGS = "-C link-arg=-fuse-ld=mold";
          };

          formatter = pkgs.nixpkgs-fmt;
        };
    };
}
