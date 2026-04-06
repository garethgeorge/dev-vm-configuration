{ pkgs, ... }:
{
  # ─── Rust: shared system-wide rustup installation ─────────────────────────
  # Toolchains live in /opt/rustup; compiled binaries in /opt/cargo/bin.
  # World-writable so any user can `cargo install` without sudo.

  environment.variables = {
    RUSTUP_HOME   = "/opt/rustup";
    CARGO_HOME    = "/opt/cargo";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig:/run/current-system/sw/share/pkgconfig";
  };

  systemd.services.rustup-init = {
    description = "Install Rust stable toolchain (one-time)";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "network-online.target" ];
    wants       = [ "network-online.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      Environment = [
        "RUSTUP_HOME=/opt/rustup"
        "CARGO_HOME=/opt/cargo"
        "HOME=/root"
      ];
      ExecStart = pkgs.writeShellScript "rustup-init" ''
        set -euo pipefail
        if [ -f /opt/rustup/.initialized ]; then
          echo "rustup already initialized, skipping"
          exit 0
        fi
        mkdir -p /opt/rustup /opt/cargo
        ${pkgs.rustup}/bin/rustup toolchain install stable --no-self-update
        ${pkgs.rustup}/bin/rustup default stable
        touch /opt/rustup/.initialized
        # Make readable + writable so any user can cargo install
        chmod -R a+rwX /opt/rustup /opt/cargo
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    rustup
  ];
}
