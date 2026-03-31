{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./modules/shell.nix
    ./modules/rust.nix
    ./modules/packages.nix
  ];

  # ─── Lima / NixOS base ────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "@wheel" ];

  services.lima.enable = true;
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  boot = {
    kernelParams = [ "console=tty0" ];
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  fileSystems."/boot" = {
    device = lib.mkForce "/dev/vda1";
    fsType = "vfat";
  };
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  system.stateVersion = "25.11";
}
