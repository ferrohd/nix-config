{ config, lib, pkgs, ... }:

{
  # ── OS-level account ────────────────────────────────────────────────────
  users.users.ferro = {
    isNormalUser = true;
    description = "Alessandro";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "video"
      "audio"
      "input"
      "render"
    ]
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
