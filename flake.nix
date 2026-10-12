{
  description = "ponds upon ponds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, ... }@inputs:
    let
      inherit (nixpkgs.lib) nixosSystem;

      mkSystem = system: hostname: modules: nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          agenix.nixosModules.default
          ./hosts/${hostname}/configuration.nix
        ] ++ modules;
      };
    in
    {
      nixosConfigurations = {
        duckweb-beak = mkSystem "x86_64-linux" "duckweb-beak" [];
        duckweb-wings = mkSystem "x86_64-linux" "duckweb-wings" [];
      };
    };
}
