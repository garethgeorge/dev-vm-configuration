{ pkgs, ... }:
{
  # ─── System Packages ────────────────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    # Terminal compatibility (terminfo for various terminals)
    ghostty.terminfo
    kitty.terminfo
    wezterm.terminfo
    foot            # includes terminfo
    ncurses         # base terminfo database

    # Languages / runtimes
    go
    python3
    python3Packages.pip
    nodejs  # LTS

    # Version control
    git
    gh  # GitHub CLI

    # AI CLIs
    claude-code  # `claude` command
    gemini-cli   # Google Gemini CLI

    # C / C++ toolchain
    gcc
    clang
    cmake
    gnumake
    pkg-config
    binutils

    # Dev utilities
    just  # command runner
    ncdu
    htop
    btop
    tmux
    neovim
    vim
    jq
    ripgrep
    tree
    unzip
    zip
    curl
    wget
    file
    lsof
    bash
  ];
}
