{ disko, ... }:

{
  imports = [
    disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../profiles/core.nix
    ../../profiles/pkgs/base.nix
    ../../profiles/network/wireguard.nix
    ../../profiles/apps/nginx
  ];

  networking.hostName = "duckweb-wings";

  duckweb.node = {
    hostDir = ./.;
    wgIp = "10.100.0.2";
    wgPubKey = "OdL+kWltWbLcAv5llClI+4O8AIqPyZSIeZxRqOQ3gXk=";
    sshHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINPonYNS5d+CK9pYWOGG4qMGTjeBDYEOX37VEGZql3LC root@duckweb-wings";
  };
}
