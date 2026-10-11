{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/packages/base.nix
  ];

  networking.hostName = "duckweb-beak";
}
