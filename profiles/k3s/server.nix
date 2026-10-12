{ config, pkgs, ... }:

{
  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;

  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.age.secrets.k3s-token.path;
    extraFlags = toString [
      "--disable traefik"
      "--tls-san=beak.yayaduck.com"
    ];
  };

  environment.systemPackages = [ pkgs.k3s ];
}
