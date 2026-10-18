{
  adminSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgmsIaUpS5pT44ZztnEWYIb4+8A6lBYfWnr6Ow32STj yayad@duckietop - ubuntu@duckweb";

  hub = {
    name = "duckweb-beak";
    endpoint = "beak.yayaduck.com:51820";
    subnet = "10.100.0.0/24";
  };

  nodes = {
    duckweb-beak = {
      wgIp = "10.100.0.1";
      wgPubKey = "TnGJUHyQSsmsELI1UT+jXwE1BK7adkeiwk+qWYu/7xA=";
      sshHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgnN8OjT2vrchLCelmfHTqDyoo2EWmTdyOlQAOG0U1k root@nixos";
    };

    duckweb-wings = {
      wgIp = "10.100.0.2";
      wgPubKey = "OdL+kWltWbLcAv5llClI+4O8AIqPyZSIeZxRqOQ3gXk=";
      sshHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINPonYNS5d+CK9pYWOGG4qMGTjeBDYEOX37VEGZql3LC root@duckweb-wings";
    };
  };

  clients = {
    quackietop = {
      wgIp = "10.100.0.100";
      wgPubKey = "QpiEiZLxCVotQyI5BNrXG0MrqzVLiam5y2TYWULAn1w=";
    };
  };
}
