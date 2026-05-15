{ pkgs, inputs, ... }:

{
  # ── Nix daemon settings ─────────────────────────────────────────────────
  nix = {
    package = pkgs.nixVersions.latest;

    # Pin the registry so `nix run nixpkgs#foo` uses this exact nixpkgs
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
    };

    # Keep flake inputs in the store for offline eval
    channel.enable = false;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    settings = {
      # Enable flakes & the new nix command
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Build optimisation
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0; # use all cores per build
      sandbox = true;

      # Trusted users (can push to binary caches, etc.)
      trusted-users = [ "root" "@wheel" ];
      allowed-users = [ "@wheel" ];

      # Substituters (binary caches)
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://cache.thalheim.io"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+OfTPnbbGVh6/GpKJuHvx6NZI2Cfo6fTY="
        "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
      ];

      warn-dirty = false;
    };

    # Garbage collection — weekly, keep last 7 days
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Optimise store after every build
    optimise.automatic = true;
  };
}
