{ pkgs, lib, ... }:
{
  # ─── Antigravity CLI (`agy`) & Remote Control Daemon support ──────────────
  # Enables systemd user lingering for `garethgeorge` so the `agy remote-control`
  # user daemon starts at VM boot without requiring an active SSH session, and
  # ensures `~/.local/bin/agy` is installed on first boot.
  #
  # (`agy` self-updates in place inside ~/.local/bin, so it is installed via the
  # official bootstrap script rather than an immutable /nix/store path.)

  users.users.garethgeorge.linger = true;

  # Enforce linger imperatively on activation as well (since mutableUsers = true).
  system.activationScripts.devboxAntigravityLinger = lib.stringAfter [ "users" "groups" ] ''
    ${pkgs.systemd}/bin/loginctl enable-linger garethgeorge || true
  '';

  systemd.services.antigravity-init = {
    description = "Install Google Antigravity CLI (one-time)";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "network-online.target" ];
    wants       = [ "network-online.target" ];
    path        = with pkgs; [ bash curl coreutils gnutar gzip gnused ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      User            = "garethgeorge";
      Environment = [
        "HOME=/home/garethgeorge.linux"
      ];
      ExecStart = pkgs.writeShellScript "antigravity-init" ''
        set -euo pipefail
        if [ -x "$HOME/.local/bin/agy" ]; then
          echo "agy CLI already installed, skipping"
          exit 0
        fi
        curl -fsSL https://antigravity.google/cli/install.sh | bash
      '';
    };
  };
}
