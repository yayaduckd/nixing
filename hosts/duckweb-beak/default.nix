{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/pkgs/base.nix
    ../../profiles/network/wireguard.nix
    ../../profiles/network/ingress.nix
    ../../profiles/apps/forgejo.nix
  ];

  networking.hostName = "duckweb-beak";

  duckweb.node = {
    hostDir = ./.;
    isHub = true;
    publicHostname = "beak.yayaduck.com";
    wgIp = "10.100.0.1";
    wgPubKey = "TnGJUHyQSsmsELI1UT+jXwE1BK7adkeiwk+qWYu/7xA=";
    sshHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgnN8OjT2vrchLCelmfHTqDyoo2EWmTdyOlQAOG0U1k root@nixos";

    extraPeers = [
      {
        name = "quackietop";
        wgIp = "10.100.0.100";
        wgPubKey = "QpiEiZLxCVotQyI5BNrXG0MrqzVLiam5y2TYWULAn1w";
      }
    ];
  };
}
