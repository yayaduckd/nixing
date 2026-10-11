{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/pkgs/base.nix
  ];

  networking.hostName = "duckweb-beak";
}
