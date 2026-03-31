{
  description = "Gareth's NixOS devbox";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-lima, ... }:
    let
      mkSystem = system: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-lima.nixosModules.lima
          ./configuration.nix
        ];
      };
    in {
      nixosConfigurations = {
        # "nixos" matches the default hostname of the nixos-lima base image;
        # nixos-rebuild uses the current hostname to bootstrap itself.
        nixos         = mkSystem "aarch64-linux";
        nixos-x86_64  = mkSystem "x86_64-linux";
      };
    };
}
