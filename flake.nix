{
  description = "Duckweb Bare-Metal Infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, agenix, deploy-rs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      inventory = import ./inventory.nix;

      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlays.default
          (self: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };

      mkNode = hostPath: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inventory; };
        modules = [
          agenix.nixosModules.default
          ./profiles/core.nix
          ./profiles/pkgs/base.nix
          ./profiles/network/wireguard.nix
          hostPath
        ] ++ extraModules;
      };
    in
    {
      nixosConfigurations = {
        duckweb-beak = mkNode ./hosts/duckweb-beak [ ./profiles/network/ingress.nix ];
        duckweb-wings = mkNode ./hosts/duckweb-wings [ disko.nixosModules.disko ./profiles/apps/nginx ];
      };

      deploy.nodes = builtins.mapAttrs (name: node: {
        hostname = if name == inventory.hub.name then "beak.yayaduck.com" else node.wgIp;
        sshUser = "yayad";
        profiles.system = {
          user = "root";
          path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${name};
        };
      }) inventory.nodes;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.wireguard-tools
          pkgs.nixos-anywhere
          agenix.packages.${system}.default
          deploy-rs.packages.${system}.default
        ];
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
