{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];
  networking.hostName = "duckweb-wings";
}
