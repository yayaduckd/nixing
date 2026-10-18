set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Deploy all nodes or a specific node (e.g., `just deploy duckweb-wings`)
deploy node="":
    if [ -z "{{node}}" ]; then \
      deploy -- --log-format internal-json -v |& nom --json; \
    else \
      deploy .#{{node}} -- --log-format internal-json -v |& nom --json; \
    fi

# Build and compare package/version changes against the live running system
diff node:
    #!/usr/bin/env bash
    set -euo pipefail
    nix build ".#nixosConfigurations.{{node}}.config.system.build.toplevel" -o "result-{{node}}" |& nom
    TARGET=$(nix eval --raw ".#deploy.nodes.{{node}}.hostname")
    CurrentSystem=$(ssh "yayad@${TARGET}" readlink -f /run/current-system)
    nix copy --no-check-sigs --from "ssh://yayad@${TARGET}" "$CurrentSystem"
    nvd diff "$CurrentSystem" "./result-{{node}}"
    rm -f "result-{{node}}"

# Edit or create a host's WireGuard secret (e.g., `just secret beak`)
secret host_dir:
    agenix -e "hosts/{{host_dir}}/wg.age"

# Rekey all agenix secrets after adding a new node or rotating keys
rekey:
    agenix -r

# Scaffold a new host directory and pre-generate its SSH and WireGuard keys
new-node dir_name ip:
    #!/usr/bin/env bash
    set -euo pipefail
    HOST_NAME="duckweb-{{dir_name}}"
    STAGE="/tmp/bootstrap-${HOST_NAME}"
    rm -rf "$STAGE" && mkdir -p "$STAGE/etc/ssh" "hosts/{{dir_name}}"
    umask 077

    ssh-keygen -t ed25519 -N "" -C "root@${HOST_NAME}" -f "$STAGE/etc/ssh/ssh_host_ed25519_key" -q
    SSH_PUB=$(cat "$STAGE/etc/ssh/ssh_host_ed25519_key.pub")

    WG_KEY=$(wg genkey)
    WG_PUB=$(echo "$WG_KEY" | wg pubkey)

    cat > "hosts/{{dir_name}}/default.nix" <<EOF
    { disko, ... }:

    {
      imports = [
        disko.nixosModules.disko
        ./hardware-configuration.nix
        ./disk-config.nix
        ../../profiles/core.nix
        ../../profiles/pkgs/base.nix
        ../../profiles/network/wireguard.nix
      ];

      networking.hostName = "${HOST_NAME}";

      duckweb.node = {
        hostDir = ./.;
        wgIp = "{{ip}}";
        wgPubKey = "${WG_PUB}";
        sshHostPubKey = "${SSH_PUB}";
      };
    }
    EOF

    cp hosts/wings/hardware-configuration.nix "hosts/{{dir_name}}/"
    cp hosts/wings/disk-config.nix "hosts/{{dir_name}}/"
    git add "hosts/{{dir_name}}"

    echo "$WG_KEY" | agenix -e "hosts/{{dir_name}}/wg.age"
    git add "hosts/{{dir_name}}/wg.age"

    echo "Scaffolded hosts/{{dir_name}} (${HOST_NAME} @ {{ip}})."
    echo "Run: just bootstrap {{dir_name}} <TARGET_IP>"

# Install NixOS onto a target IP using the staged SSH host keys from `just new-node`
bootstrap dir_name target_ip:
    nixos-anywhere --extra-files "/tmp/bootstrap-duckweb-{{dir_name}}" --flake ".#duckweb-{{dir_name}}" "root@{{target_ip}}"
    rm -rf "/tmp/bootstrap-duckweb-{{dir_name}}"
    just deploy duckweb-beak

# Update flake inputs and show lockfile diff
update:
    nix flake update --commit-lock-file
