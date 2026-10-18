{ config, lib, inventory, ... }:

let
  hostName = config.networking.hostName;
  isHub = hostName == inventory.hub.name;
  thisNode = inventory.nodes.${hostName};
  hubNode = inventory.nodes.${inventory.hub.name};

  otherNodes = lib.filterAttrs (n: _: n != hostName) inventory.nodes;

  hubPeers =
    (lib.mapAttrsToList (_: node: {
      publicKey = node.wgPubKey;
      allowedIPs = [ "${node.wgIp}/32" ];
    }) otherNodes)
    ++ (lib.mapAttrsToList (_: client: {
      publicKey = client.wgPubKey;
      allowedIPs = [ "${client.wgIp}/32" ];
    }) inventory.clients);

  spokePeers = [
    {
      publicKey = hubNode.wgPubKey;
      allowedIPs = [ inventory.hub.subnet ];
      endpoint = inventory.hub.endpoint;
      persistentKeepalive = 25;
    }
  ];
in
{
  age.secrets."wg-${hostName}".file = ../../secrets/wg-${hostName}.age;

  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkIf isHub 1;

  networking.firewall = {
    allowedUDPPorts = lib.mkIf isHub [ 51820 ];
    trustedInterfaces = [ "wg0" ];
  };

  networking.extraHosts = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: node: "${node.wgIp} ${name}") inventory.nodes
  );

  networking.wireguard.interfaces.wg0 = {
    ips = [ "${thisNode.wgIp}/24" ];
    listenPort = lib.mkIf isHub 51820;
    privateKeyFile = config.age.secrets."wg-${hostName}".path;
    peers = if isHub then hubPeers else spokePeers;
  };
}
