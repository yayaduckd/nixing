{ config, pkgs, ... }:

{
  age.secrets.k3s-token.file = ../../secrets/k3s-token.age;

  age.identityPaths = [
    "/var/lib/age/feather-key.txt"
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.age.secrets.k3s-token.path;
    serverAddr = "https://beak.yayaduck.com:6443";
  };

  environment.systemPackages = [ pkgs.k3s ];
}
