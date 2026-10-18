{ pkgs, ... }:

{
  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 8080 ];

  services.nginx = {
    enable = true;
    virtualHosts."_" = {
      listen = [
        {
          addr = "10.100.0.2";
          port = 8080;
        }
      ];
      root = pkgs.writeTextDir "index.html" "<h1>duckweb-wings</h1>";
    };
  };

  # Reference pattern for OCI workloads on wings:
  # virtualisation.podman.enable = true;
  # virtualisation.oci-containers = {
  #   backend = "podman";
  #   containers.app = {
  #     image = "docker.io/library/nginx:stable-alpine";
  #     ports = [ "10.100.0.2:8081:80" ];
  #   };
  # };
}
