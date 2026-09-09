{
  description = "Rust project — pinned nightly toolchain via rust-overlay";

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

          # "nightly" resolves to whichever nightly the pinned rust-overlay
          # input knows about, so builds stay reproducible — move it with
          # `nix flake update rust-overlay`.
          toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        in
        {
          devShells.default = pkgs.mkShell {
            packages = [
              toolchain
            ] ++ (with pkgs; [
              # native build deps for crates like openssl-sys
              pkg-config
              openssl
              mold
            ]);

            # nightly extras, opt in by appending:
            #   -Zthreads=8         parallel compiler frontend
            #   -Zmacro-backtrace   backtraces through macro expansion
            RUSTFLAGS = "-C link-arg=-fuse-ld=mold";
          };

          formatter = pkgs.nixpkgs-fmt;
        };
    };
}
