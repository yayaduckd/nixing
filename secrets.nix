let
  flake = builtins.getFlake (toString ./.);
  lib = flake.inputs.nixpkgs.lib;
in
lib.foldlAttrs (acc: _: nixosConfig:
  let
    cfg = nixosConfig.config;
    adminKeys = cfg.users.users.yayad.openssh.authorizedKeys.keys;
    hostKey = cfg.duckweb.node.sshHostPubKey;
    relPath = lib.removePrefix "${toString ./.}/" (toString cfg.duckweb.node.hostDir);
  in
  acc // {
    "${relPath}/wg.age".publicKeys = adminKeys ++ [ hostKey ];
  }
) {} flake.nixosConfigurations
