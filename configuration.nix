{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./modules/shell.nix
    ./modules/rust.nix
    ./modules/packages.nix
    ./modules/vim.nix
  ];

  # ─── Lima / NixOS base ────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "@wheel" ];

  services.lima.enable = true;
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Enable nix-ld for running unpatched binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # C/C++ runtime
    stdenv.cc.cc.lib
    glibc

    # Compression
    zlib
    zstd
    bzip2
    xz
    lz4

    # Crypto / TLS
    openssl
    libgcrypt
    gnutls

    # Networking
    curl
    nghttp2
    libssh2

    # System / IPC
    systemd
    dbus
    libcap
    acl
    attr
    util-linux.lib
    pam

    # Data formats
    expat
    libxml2
    sqlite
    icu

    # Math / science
    libffi

    # Graphics / GUI (headless-safe subset)
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXi
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXfixes
    xorg.libXinerama
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXtst
    xorg.libxcb
    xorg.libICE
    xorg.libSM
    libGL
    libdrm
    mesa
    vulkan-loader
    fontconfig
    freetype
    cairo
    pango
    gdk-pixbuf
    glib
    gtk3
    libxkbcommon
    wayland

    # Audio
    alsa-lib
    libpulseaudio

    # Readline / ncurses
    readline
    ncurses

    # Misc
    libuuid
    libusb1
    libidn2
    libgpg-error
  ];

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
