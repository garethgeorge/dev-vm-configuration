{
  description = "Gareth's portable NixOS devbox (lima)";

  inputs = {
    # Keep in step with the nixos-lima image release in lima/base.yaml —
    # v0.2.x images are built from nixos-26.05.
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima/v0.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-lima, claude-code-nix, ... }:
    let
      mkSystem = system: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit claude-code-nix; };
        modules = [
          nixos-lima.nixosModules.lima
          ./configuration.nix
        ];
      };
    in {
      # Never selected by hostname: scripts/apply.sh always passes an explicit
      # attr, /flake#devbox-$(uname -m). Relying on the hostname would silently
      # pick the wrong architecture on half the machines.
      nixosConfigurations = {
        devbox-aarch64 = mkSystem "aarch64-linux";
        devbox-x86_64  = mkSystem "x86_64-linux";
      };
    };
}
