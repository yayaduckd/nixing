{
  description = "ponds upon ponds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs.lib) nixosSystem;

      mkSystem = system: hostname: modules: nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}/configuration.nix
        ] ++ modules;
      };
    in
    {
      nixosConfigurations = {
        duckweb-beak = mkSystem "x86_64-linux" "duckweb-beak" [];

        # duckweb-thighs = mkSystem "aarch64-linux" "duckweb-thighs" [
        #   ./profiles/packages/ptero.nix
        # ];
      };
    };
}
