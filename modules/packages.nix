{ pkgs, claude-code-nix, ... }:
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
    go_1_26
    python3
    python3Packages.pip
    nodejs  # LTS
    pnpm

    # Media tools
    (ffmpeg.override { withSvtav1 = true; })

    # Version control
    git
    git-lfs
    gh  # GitHub CLI

    # AI CLIs
    claude-code-nix.packages.${stdenv.hostPlatform.system}.default  # `claude` command
    gemini-cli   # Google Gemini CLI

    # C / C++ toolchain
    gcc
    clang
    cmake
    gnumake
    pkg-config
    binutils

    # Protobuf toolchain
    protobuf                      # protoc compiler
    buf                           # linting, breaking change detection, BSR
    grpc-tools                    # grpc_cpp_plugin, grpc_node_plugin, etc.
    protoc-gen-go                 # Go
    protoc-gen-go-grpc            # Go gRPC services
    protoc-gen-rust               # Rust
    protoc-gen-js                 # JavaScript
    protoc-gen-es                 # TypeScript / ECMAScript (connect/buf ecosystem)
    python3Packages.grpcio-tools  # Python (includes grpc_python_plugin)

    # Common dev libraries (headers + CLI tools on PATH)
    openssl          # openssl CLI + libssl/libcrypto
    openssl.dev      # .pc files + headers for pkg-config
    zlib             # compression (many build systems expect this)
    zlib.dev
    sqlite           # sqlite3 CLI + dev headers
    sqlite.dev
    libffi           # foreign function interface
    libffi.dev
    readline         # line editing (Python, Ruby, etc.)
    readline.dev
    libyaml          # YAML parsing
    libyaml.dev
    libxml2          # XML parsing + xmllint
    libxslt          # XSLT processor

    # Dev utilities
    eza   # modern ls replacement (exa fork)
    just  # command runner
    dua   # disk usage analyzer
    ncdu
    htop
    btop
    tmux
    neovim
    clang-tools  # clangd for C/C++ LSP
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

    # Language servers
    nil                                    # Nix
    rust-analyzer                          # Rust
    gopls                                  # Go
    nodePackages.typescript-language-server # TypeScript/JavaScript
    pyright                                # Python
  ];
}
