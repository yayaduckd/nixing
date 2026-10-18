{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@yayaduck.com";
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."beak.yayaduck.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.100.0.2:8080";
        proxyWebsockets = true;
      };
    };
  };
}
