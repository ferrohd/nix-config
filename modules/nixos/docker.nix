{ pkgs, lib, ... }:

{
  # ── Containers & Virtualisation ─────────────────────────────────────────
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" "--volumes" ];
      };
      # Use the storage driver best suited for your filesystem
      storageDriver = lib.mkDefault "overlay2";
    };

    # Podman as rootless alternative
    podman = {
      enable = true;
      dockerCompat = false; # set true if you want `docker` alias
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker   # TUI for Docker
    dive         # Inspect Docker image layers
  ];
}
