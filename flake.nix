{
  description = "Fuzzy find through nixpkgs";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = builtins.attrNames inputs.nixpkgs.legacyPackages;
      perSystem = {pkgs, ...}: rec {
        packages = pkgs.callPackage ./packages.nix {inherit nixpkgs;}; 
        devShells.default = pkgs.mkShell {
          packages = [packages.fzf-nix pkgs.alejandra pkgs.deadnix pkgs.statix];
        };
      };
    };
}
