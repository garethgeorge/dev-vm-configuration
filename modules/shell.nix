{ pkgs, ... }:
{
  # ─── Shell: zsh + oh-my-posh ───────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    interactiveShellInit = ''
      # oh-my-posh prompt
      eval "$(oh-my-posh init zsh --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/catppuccin.omp.json)"

      # fzf shell integration
      source <(fzf --zsh)

      # PATH extras
      export PATH=$PATH:$HOME/go/bin:$HOME/.local/bin:/opt/cargo/bin

      # Use eza (exa fork) as default ls
      alias ls="eza"
      alias ll="eza -l"
      alias la="eza -la"

      # ─── NixOS rebuild helpers ──────────────────────────────────────────────
      # The flake repo is host-mounted at /flake on every machine; edit it on
      # the host (or in the VM) and re-apply. apply.sh picks the right flake
      # attr for this arch and sudo's as needed.
      alias nrs="/flake/scripts/apply.sh switch"
      alias nrt="/flake/scripts/apply.sh test"
      alias nrb="/flake/scripts/apply.sh build"
      alias nrdry="/flake/scripts/apply.sh dry-activate"

      # Quick edit helpers (expand $EDITOR at use time)
      alias nconf='$EDITOR /flake/configuration.nix'
      alias nflake='$EDITOR /flake/flake.nix'
      alias npkgs='$EDITOR /flake/modules/packages.nix'
      alias nshell='$EDITOR /flake/modules/shell.nix'

      # Garbage collection
      alias ngc="sudo nix-collect-garbage -d"
    '';
  };

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
