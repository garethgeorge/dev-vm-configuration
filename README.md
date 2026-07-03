# dev-vm-configuration

One NixOS dev VM, portable across all my machines via [lima](https://lima-vm.io)
and [nixos-lima](https://github.com/nixos-lima/nixos-lima). The same flake
drives every host; only mounts and resources differ per machine.

```
flake.nix               nixosConfigurations.devbox-{aarch64,x86_64}
configuration.nix       shared system config (boot/fs mirror nixos-lima's image)
modules/
  user.nix              the devbox user (SSH-safety rules documented inside)
  shell.nix             zsh, prompt, rebuild aliases
  packages.nix          dev toolchain
  nix-ld.nix            libraries for running unpatched binaries
  rust.nix              system-wide rustup in /opt
  vim.nix               vim + LSP
scripts/
  apply.sh              THE rebuild entry point (first boot + interactive)
lima/
  base.yaml             everything shared: image, user, mounts, provisioning
  macos.yaml            M4 MacBook Pro   (arm, vz+virtiofs)
  workstation.yaml      x86 workstation  (16 GB host → 8 GiB VM)
  nas.yaml              x86 NAS          (32 GB host → 16 GiB VM)
```

## Starting a VM

Pick the file for the machine you're on. **First edit its `/flake` mount
`location`** to point at this repo's checkout on that machine, then:

```sh
limactl start lima/macos.yaml --name devbox        # or workstation.yaml / nas.yaml
limactl shell devbox                                # zsh once provisioned
limactl shell devbox -- journalctl -fu devbox-init  # watch the first build
```

First boot: the stock nixos-lima image comes up, `devbox-init` waits for the
`/flake` mount, then runs `scripts/apply.sh` to build this flake directly from
the mount. Requires limactl ≥ 2.1 (the pinned v0.2.1 images pair with it).

## Day-to-day

The repo is **mounted** at `/flake`, never copied. Edit it on the host or in
the VM, then re-apply from inside the VM:

```sh
nrs     # nixos-rebuild switch  (alias for /flake/scripts/apply.sh switch)
nrt     # ... test — activate without adding a boot entry
nrb     # ... build only
nrdry   # ... dry-activate
```

`apply.sh` selects the flake attr by architecture (`devbox-$(uname -m)`), so
never rely on hostname-based selection. It fetches the flake as `path:/flake`,
not `git+file:` — over the mount the repo is owned by the host uid and root's
libgit2 refuses it ("repository not owned by current user"). Consequences:

- Everything in the directory is part of the build, tracked or not — no
  `git add` needed for new files, but stray junk directories get copied to
  the nix store too.
- Changing `inputs` in flake.nix re-locks on the next apply (writes
  `flake.lock` through the mount). To update inputs deliberately:
  `nix flake update path:/flake` from inside the VM, then `nrs`.

## The rules that keep SSH working

Losing SSH to the VM is the historic failure mode of this setup. Three
invariants prevent it:

1. **Never mount over `/home`, `/root`, `/etc`, or any parent of them.**
   Host mounts shadow the guest directories where lima-init writes SSH keys.
   Use `/mnt/<name>` or `/flake` (full explanation in `lima/base.yaml`).
2. **Never declare `openssh.authorizedKeys` in the flake.** NixOS writes
   declared keys to `/etc/ssh/authorized_keys.d/<user>` — the same file
   lima-init owns — and each clobbers the other (see `modules/user.nix`).
   lima-init re-injects the host's lima key on every boot; that is the sole
   key mechanism.
3. **The guest user and home are pinned identically in two places**:
   `user:` in `lima/base.yaml` and `users.users.*` in `modules/user.nix`.
   Lima 2.x otherwise defaults the home to `/home/<user>.guest`, and a
   home mismatch sends injected keys to the wrong directory. Change both
   together or neither.

## Editing the lima templates

Shared config belongs in `lima/base.yaml`; host files hold only mounts and
resources. Merge rules and the reasons behind them are documented at the top
of `base.yaml`. To debug what a host actually gets:

```sh
limactl template validate lima/*.yaml
limactl template copy --embed lima/nas.yaml -   # render the merged template
```

(Avoid `--fill`/`template yq` on any template with a `param:` section —
limactl 2.1.3 crashes on those; this repo avoids `param:` entirely.)

## Upgrading the base image

Bump together, they are one unit:

1. `images:` locations + digests in `lima/base.yaml` (from the
   [nixos-lima releases](https://github.com/nixos-lima/nixos-lima/releases))
2. `nixos-lima` input tag and `nixpkgs` release in `flake.nix`
3. `system.stateVersion` in `configuration.nix` (fresh VMs only)

Existing instances built from older images are best recreated
(`limactl delete devbox && limactl start ...`) rather than upgraded in place.
