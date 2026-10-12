{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/pkgs/base.nix

    ../../profiles/k3s/server.nix
  ];

  networking.hostName = "duckweb-beak";
}
