{ config, pkgs, ... }:

{
  age.secrets.immich-db-pass.file = ../../../secrets/immich-db-pass.age;

  systemd.services.deploy-immich = {
    description = "Deploy Immich via Helmfile";
    after = [ "k3s.service" ];
    wants = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ kubernetes-helm bash k3s ];

    environment = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      DB_PASS_FILE = config.age.secrets.immich-db-pass.path;
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'until kubectl get namespace; do sleep 2; done'";
      ExecStart = "${pkgs.helmfile}/bin/helmfile -f ${./helmfile.yaml} sync";
    };
  };
}
