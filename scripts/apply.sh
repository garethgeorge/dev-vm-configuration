#!/usr/bin/env bash
# Build & activate the NixOS config from the flake mounted at /flake.
#
# This is the single entry point for applying the flake, shared by:
#   • the first-boot provisioning unit (lima/base.yaml → devbox-init)
#   • the interactive aliases in modules/shell.nix (nrs / nrt / nrb / nrdry)
#
# Usage: apply.sh [switch|boot|test|build|dry-activate]   (default: switch)
set -euo pipefail

FLAKE_DIR="${DEVBOX_FLAKE:-/flake}"
ACTION="${1:-switch}"

# Re-exec from /tmp: activation stops the lima mounts (see below), and a bash
# still reading this script from /flake would hold the mount busy and make
# the unmount — and thus the whole switch — fail nondeterministically.
if [ -z "${DEVBOX_APPLY_RELOCATED:-}" ]; then
  tmp="$(mktemp /tmp/devbox-apply.XXXXXX)"
  cp "$0" "$tmp"
  DEVBOX_APPLY_RELOCATED=1 exec bash "$tmp" "$@"
fi
cd /

# nixos-rebuild picks the config by hostname unless told otherwise; the
# hostname is the same on every machine, so select by architecture instead.
case "$(uname -m)" in
  aarch64) ATTR="devbox-aarch64" ;;
  x86_64)  ATTR="devbox-x86_64" ;;
  *) echo "apply.sh: unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

SUDO=""
if [ "$(id -u)" -ne 0 ] && [ "$ACTION" != "build" ]; then
  SUDO="sudo"
fi

# path: (not git+file:) — /flake is owned by the host uid over the mount, and
# root's nixos-rebuild would hit libgit2's "repository not owned by current
# user" refusal. path: skips git entirely; it also means untracked files ARE
# part of the build (no `git add` needed for new .nix files).
echo "==> nixos-rebuild $ACTION --flake path:$FLAKE_DIR#$ATTR"
status=0
$SUDO nixos-rebuild "$ACTION" --flake "path:$FLAKE_DIR#$ATTR" || status=$?

# switch/test regenerate /etc/fstab, wiping the mount entries lima-init
# appended — systemd then stops those now-undeclared mounts, including
# /flake itself. lima-init is idempotent: restarting it re-appends the
# entries and remounts everything.
if [ ! -e "$FLAKE_DIR/flake.nix" ]; then
  echo "==> host mounts were dropped by the activation; restarting lima-init to remount"
  $SUDO systemctl restart lima-init
fi

rm -f "$0"
exit "$status"
