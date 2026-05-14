{ pkgs, ... }:

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
    ];
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAA... ferro@blackmesa"
    ];
  };

  programs.zsh.enable = true;
}
