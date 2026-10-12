{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/pkgs/base.nix

    ../../profiles/k3s/agent.nix
  ];

  networking.hostName = "duckweb-wings";
}
