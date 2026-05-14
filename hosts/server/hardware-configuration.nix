# hosts/server/hardware-configuration.nix
# Replace with output of: sudo nixos-generate-config --show-hardware-config
{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems."/" = { device = "/dev/disk/by-uuid/REPLACE-ME"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/REPLACE-ME"; fsType = "vfat"; };
  swapDevices = [ ];

  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
