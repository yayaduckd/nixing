{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/pkgs/base.nix

    ../../profiles/k3s/server.nix
    ../../profiles/apps/nginx
  ];

  networking.hostName = "duckweb-beak";
}
