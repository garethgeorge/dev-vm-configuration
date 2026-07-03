{ pkgs, lib, modulesPath, ... }:
{
  imports = [
    # nixos-lima's exported flake module only ships lima-init (cidata user +
    # mounts + guest agent). The boot/filesystem config its images are built
    # with lives in nixos-lima's lima.nix, which is NOT exported — so it is
    # replicated below and must stay compatible with the image release pinned
    # in lima/base.yaml.
    (modulesPath + "/profiles/qemu-guest.nix")
    ./modules/user.nix
    ./modules/shell.nix
    ./modules/rust.nix
    ./modules/packages.nix
    ./modules/vim.nix
    ./modules/nix-ld.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "@wheel" ];

  services.lima.enable = true;
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # lima-init creates/adjusts the lima user imperatively at every boot;
  # nixos-rebuild must never wipe it or login breaks.
  users.mutableUsers = true;

  # ─── Boot / filesystems (mirrors nixos-lima's lima.nix) ──────────────────
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
    device = lib.mkForce "/dev/vda1"; # /dev/disk/by-label/ESP
    fsType = "vfat";
  };
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  # Matches the NixOS release the v0.2.x nixos-lima images are built from.
  system.stateVersion = "26.05";
}
