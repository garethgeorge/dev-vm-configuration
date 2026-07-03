{ pkgs, lib, ... }:
{
  # ─── The devbox user ───────────────────────────────────────────────────────
  # lima/base.yaml pins the guest user to this same name and home
  # (user.name / user.home), so every host machine — mac, workstation, NAS —
  # produces the identical account regardless of the host-side username.
  # If you rename the user here, rename it in lima/base.yaml too.
  #
  # ⚠ SSH access is managed by lima-init on every boot: it writes lima's
  # per-host public key to ~/.ssh/authorized_keys AND to
  # /etc/ssh/authorized_keys.d/<user>. Do NOT declare
  # users.users.*.openssh.authorizedKeys here — NixOS writes the declared
  # list to that same /etc/ssh/authorized_keys.d/<user> file on every
  # rebuild, so the two mechanisms overwrite each other and a rebuild can
  # lock you out of the VM. Likewise nothing in this flake may manage the
  # home directory itself (no home-manager over ~/.ssh).
  users.users.garethgeorge = {
    isNormalUser = true;
    # Must match user.home in lima/base.yaml. Lima 2.x defaults to
    # /home/<user>.guest, so both sides pin it explicitly.
    home = "/home/garethgeorge.linux";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"   # sudo access
      "docker"  # docker without sudo
      "kvm"     # virtualization/emulation
      "dialout" # serial ports (embedded dev)
    ];
  };

  users.defaultUserShell = pkgs.zsh;

  # lima-init creates this user at first boot BEFORE the first rebuild runs,
  # and with mutableUsers = true NixOS never modifies an existing user — so
  # the declared shell/extraGroups above only take effect on machines where
  # the user didn't exist yet (i.e. never, under lima). Enforce them
  # imperatively on every activation instead.
  system.activationScripts.devboxUserFixup = lib.stringAfter [ "users" "groups" ] ''
    ${pkgs.shadow}/bin/usermod -s ${pkgs.zsh}/bin/zsh garethgeorge || true
    ${pkgs.shadow}/bin/usermod -aG wheel,docker,kvm,dialout garethgeorge || true
  '';

  virtualisation.docker.enable = true;
}
