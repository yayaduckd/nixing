{ config, lib, nodes, ... }:

let
  cfg = config.duckweb.node;

  allNodes = lib.mapAttrs (_: n: n.config.duckweb.node) nodes;
  otherNodes = lib.filterAttrs (name: _: name != config.networking.hostName) allNodes;
  hubNode = lib.head (lib.attrValues (lib.filterAttrs (_: n: n.isHub) allNodes));

  hubPeers =
    (lib.mapAttrsToList (_: node: {
      publicKey = node.wgPubKey;
      allowedIPs = [ "${node.wgIp}/32" ];
    }) otherNodes)
    ++ (map (client: {
      publicKey = client.wgPubKey;
      allowedIPs = [ "${client.wgIp}/32" ];
    }) cfg.extraPeers);

  spokePeers = [
    {
      publicKey = hubNode.wgPubKey;
      allowedIPs = [ "10.100.0.0/24" ];
      endpoint = "${hubNode.publicHostname}:51820";
      persistentKeepalive = 25;
    }
  ];
in
{
  options.duckweb.node = {
    hostDir = lib.mkOption { type = lib.types.path; };
    isHub = lib.mkOption { type = lib.types.bool; default = false; };
    publicHostname = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    wgIp = lib.mkOption { type = lib.types.str; };
    wgPubKey = lib.mkOption { type = lib.types.str; };
    sshHostPubKey = lib.mkOption { type = lib.types.str; };
    extraPeers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          wgIp = lib.mkOption { type = lib.types.str; };
          wgPubKey = lib.mkOption { type = lib.types.str; };
        };
      });
      default = [];
    };
  };

  config = {
    age.secrets.wg.file = "${cfg.hostDir}/wg.age";

    boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkIf cfg.isHub 1;

    networking.firewall = {
      allowedUDPPorts = lib.mkIf cfg.isHub [ 51820 ];
      trustedInterfaces = [ "wg0" ];
    };

    networking.extraHosts = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (_: n: "${n.config.duckweb.node.wgIp} ${n.config.networking.hostName}") nodes
    );

    networking.wireguard.interfaces.wg0 = {
      ips = [ "${cfg.wgIp}/24" ];
      listenPort = lib.mkIf cfg.isHub 51820;
      privateKeyFile = config.age.secrets.wg.path;
      peers = if cfg.isHub then hubPeers else spokePeers;
    };
  };
}
