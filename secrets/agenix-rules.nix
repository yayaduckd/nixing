let
  inventory = import ../inventory.nix;

  nodeSecrets = builtins.listToAttrs (
     builtins.map (name: {
      name = "wg-${name}.age";
      value = {
        publicKeys = [
          inventory.adminSshKey
          inventory.nodes.${name}.sshHostPubKey
        ];
      };
    }) (builtins.attrNames inventory.nodes)
  );
in
nodeSecrets
