{ config, lib, pkgs, ... }:

{
  # ── OS-level account ────────────────────────────────────────────────────
  users.users.ferro = {
    isNormalUser = true;
    description = "Alessandro";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
      "render"
    ]
    # Service groups only exist where the service is enabled (DNS nodes run
    # neither NetworkManager nor Docker).
    ++ lib.optional config.networking.networkmanager.enable "networkmanager"
    ++ lib.optional config.virtualisation.docker.enable "docker"
    # Sunshine needs uinput to create virtual gamepads/mouse/keyboard.
    # services.sunshine implies hardware.uinput.enable, which is what creates
    # the group — on hosts without it (server) the group does not exist.
    ++ lib.optional config.hardware.uinput.enable "uinput";
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAA... ferro@blackmesa"
    ];
  };

  programs.zsh.enable = true;
}
