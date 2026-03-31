{ pkgs, ... }:
{
  # ─── Shell: zsh + oh-my-posh ───────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    interactiveShellInit = ''
      # oh-my-posh prompt
      eval "$(oh-my-posh init zsh --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/bubblesextra.omp.json)"

      # fzf shell integration
      source <(fzf --zsh)

      # PATH extras
      export PATH=$PATH:$HOME/go/bin:$HOME/.local/bin:/opt/cargo/bin

      # ─── NixOS rebuild aliases ──────────────────────────────────────────────
      # Flake source on the Mac mount (edits on Mac are immediately visible)
      export DEVBOX_FLAKE="/Users/garethgeorge/Documents/github/devboxes/nixos-devbox"

      # Rebuild and switch to new configuration
      alias nrs="sudo nixos-rebuild switch --flake \$DEVBOX_FLAKE"

      # Rebuild, switch, and show what changed
      alias nrsd="sudo nixos-rebuild switch --flake \$DEVBOX_FLAKE && nix-diff /run/current-system"

      # Test build without switching (useful for catching errors)
      alias nrt="sudo nixos-rebuild test --flake \$DEVBOX_FLAKE"

      # Build only (no switch, no boot entry)
      alias nrb="sudo nixos-rebuild build --flake \$DEVBOX_FLAKE"

      # Show current vs new generation diff before switching
      alias nrdry="nixos-rebuild dry-activate --flake \$DEVBOX_FLAKE 2>&1 | head -50"

      # Quick edit helpers (opens in $EDITOR on the Mac-mounted files)
      alias nconf="$EDITOR \$DEVBOX_FLAKE/configuration.nix"
      alias nflake="$EDITOR \$DEVBOX_FLAKE/flake.nix"
      alias npkgs="$EDITOR \$DEVBOX_FLAKE/modules/packages.nix"
      alias nshell="$EDITOR \$DEVBOX_FLAKE/modules/shell.nix"

      # Garbage collection
      alias ngc="sudo nix-collect-garbage -d"
    '';
  };

  users.defaultUserShell = pkgs.zsh;

  # Define the primary user
  users.users.garethgeorge = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"   # sudo access
      "docker"  # docker without sudo
      "kvm"     # virtualization/emulation
      "dialout" # serial ports (embedded dev)
    ];
  };
  users.groups.garethgeorge = {};

  # Enable docker
  virtualisation.docker.enable = true;

  # Shell-related packages
  environment.systemPackages = with pkgs; [
    fzf
    zsh
    oh-my-posh
  ];

  # Nerd font for oh-my-posh icons
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
