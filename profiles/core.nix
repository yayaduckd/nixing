{ agenix, ... }:

{
  imports = [ agenix.nixosModules.default ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "yayad" "@wheel" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking.firewall.enable = true;

  users.users = {
    root.hashedPassword = "!";
    yayad = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgmsIaUpS5pT44ZztnEWYIb4+8A6lBYfWnr6Ow32STj yayad@duckietop - ubuntu@duckweb"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  system.stateVersion = "26.05";
}
