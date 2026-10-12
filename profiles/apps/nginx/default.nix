{ pkgs, ... }:

{
  systemd.services.deploy-nginx = {
    description = "Deploy NGINX via Helmfile";
    after = [ "k3s.service" ];
    wants = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ kubernetes-helm bash k3s ];

    environment = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      HELM_CACHE_HOME = "/var/cache/helm";
      HELM_CONFIG_HOME = "/var/lib/helm/config";
      HELM_DATA_HOME = "/var/lib/helm/data";
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "helm";
      CacheDirectory = "helm";
      WorkingDirectory = "/var/lib/helm";
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'until kubectl get namespace; do sleep 2; done'";
      ExecStart = "${pkgs.bash}/bin/bash -c 'cp ${./helmfile.yaml} helmfile.yaml && ${pkgs.helmfile}/bin/helmfile -f helmfile.yaml sync'";
    };
  };
}
