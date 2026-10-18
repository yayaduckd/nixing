{ pkgs, config, ... }:

let
  domain = "git.yayaduck.com";
  httpPort = 3000;
in
{
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    database.type = "postgres";
    lfs.enable = true;

    settings = {
      DEFAULT.APP_NAME = "Duckweb Git";
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = httpPort;
        SSH_DOMAIN = domain;
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
      session = {
        COOKIE_SECURE = true;
      };
    };
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString httpPort}";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 512M;
      '';
    };
  };
}
