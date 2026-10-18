{
  description = "ponds upon ponds";

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

      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlays.default
          (final: prev: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = prev.deploy-rs.lib;
            };
          })
        ];
      };

      hostDirs = builtins.attrNames (
        nixpkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts)
      );

      mkHost = dirName: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit disko agenix;
          nodes = self.nixosConfigurations;
        };
        modules = [ ./hosts/${dirName} ];
      };
    in
    {
      nixosConfigurations = builtins.listToAttrs (
        map (dirName: {
          name = (mkHost dirName).config.networking.hostName;
          value = mkHost dirName;
        }) hostDirs
      );

      deploy.nodes = builtins.mapAttrs (_: nixosConfig:
        let
          nodeCfg = nixosConfig.config.duckweb.node;
        in
        {
          hostname = if nodeCfg.publicHostname != null then nodeCfg.publicHostname else nodeCfg.wgIp;
          sshUser = "yayad";
          profiles.system = {
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos nixosConfig;
          };
        }
      ) self.nixosConfigurations;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.just
          pkgs.wireguard-tools
          pkgs.nixos-anywhere
          pkgs.nix-output-monitor
          pkgs.nvd
          pkgs.nixd
          pkgs.nixfmt-rfc-style
          agenix.packages.${system}.default
          deploy-rs.packages.${system}.default
        ];
      };

      checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
