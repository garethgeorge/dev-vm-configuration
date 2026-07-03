{ pkgs, ... }:
{
  # ─── nix-ld: run unpatched dynamically-linked binaries ────────────────────
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
    libx11
    libxext
    libxrender
    libxi
    libxcursor
    libxrandr
    libxfixes
    libxinerama
    libxcomposite
    libxdamage
    libxtst
    libxcb
    libice
    libsm
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
}
