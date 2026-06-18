default:
    just --list --unsorted --list-heading $'Available repo commands\n'

# deploy locally - mention host name to deploy remotely
deploy machine='':
    #!/usr/bin/env sh
    if [ -z "{{ machine }}" ]; then
      if command -v darwin-rebuild &> /dev/null 2>&1; then
        darwin-rebuild switch --flake ~/.nix-config
      else
        nh os switch
      fi
    elif [ {{ machine }} = "nami" ]; then
      just deploy-nami
    elif [ {{ machine }} = "zoro" ]; then
      just deploy-zoro
    elif [ {{ machine }} = "usopp" ]; then
      just deploy-usopp
    elif [ {{ machine }} = "chopper" ]; then
      just deploy-chopper
    elif [ {{ machine }} = "kube" ]; then
      just deploy-zoro
      just deploy-usopp
      just deploy-chopper
    elif [ {{ machine }} = "all" ]; then
      just deploy-nami
      just deploy-zoro
      just deploy-usopp
      just deploy-chopper
    fi

# Remote deploy nami
deploy-nami:
    nixos-rebuild switch --no-reexec --flake ".#nami" --accept-flake-config --elevate=sudo --target-host "vijay@10.0.0.2" --build-host "vijay@10.0.0.2"

# Remote deploy zoro
deploy-zoro:
    nixos-rebuild switch --no-reexec --flake ".#zoro" --accept-flake-config --elevate=sudo --target-host "vijay@10.0.1.101" --build-host "vijay@10.0.1.101"

# Remote deploy usopp
deploy-usopp:
    nixos-rebuild switch --no-reexec --flake ".#usopp" --accept-flake-config --elevate=sudo --target-host "vijay@10.0.1.102" --build-host "vijay@10.0.1.102"

# Remote deploy chopper
deploy-chopper:
    nixos-rebuild switch --no-reexec --flake ".#chopper" --accept-flake-config --elevate=sudo --target-host "vijay@10.0.1.103" --build-host "vijay@10.0.1.103"

deploy-robin:
    nixos-rebuild switch --no-reexec --flake ".#robin" --accept-flake-config --elevate=sudo --target-host "robin-build" --build-host "robin-build"

# update flake.lock
up:
    git pull
    nix flake update

# update flake.lock commit it
up-commit:
    git pull
    nix flake update --commit-lock-file

# Nix garbage collect
gc:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d && sudo nix store gc

# Repair nix shore
repair:
    sudo nix-store --verify --check-contents --repair

# Edit secrets yaml
secrets-edit:
    sops secrets.yaml

# generate new data encryption key and reencrypt all values
secrets-rotate:
    sops --rotate --in-place secrets.yaml

# update/add new secrets with new keys
secrets-sync:
    sops updatekeys --yes secrets.yaml

# Build nixos install ISO
iso:
    nix build -L --accept-flake-config .#nixosConfigurations.nixiso.config.system.build.isoImage && attic push system ./result

# build SdImage for pi(Nami)
pi-img:
    nix build -L --accept-flake-config .#nixosConfigurations.nami.config.system.build.sdImage --system "aarch64-linux" && attic push system ./result

# Build and upload cache to attic for all host
cache:
    just up
    just cache-zoro
    just cache-usopp
    just cache-nixiso
    just cache-nami
    rm ./result

# Build and upload cache to attic for zoro host
cache-zoro:
    nix build --accept-flake-config .#nixosConfigurations.zoro.config.system.build.toplevel && cachix push vijay ./result

# Build and upload cache to attic for usopp host
cache-usopp:
    nix build --accept-flake-config .#nixosConfigurations.usopp.config.system.build.toplevel && cachix push vijay ./result

# Build and upload cache to attic for kakashi host
cache-kakashi:
    nix build --accept-flake-config .#darwinConfigurations.kakashi.config.system.build.toplevel --system "aarch64-darwin" --impure && attic push system  && cachix push vijay ./result./result

# Build and upload cache to attic for nami host
cache-nami:
    nix build -L --accept-flake-config .#nixosConfigurations.nami.config.system.build.toplevel --system "aarch64-linux" && cachix push vijay ./result

# Build and upload cache to attic for nixiso build
cache-nixiso:
    nix build --accept-flake-config .#nixosConfigurations.nixiso.config.system.build.toplevel && cachix push vijay ./result

# Bootstrap a new NixOS machine using nixos-anywhere, automatically handling sops-nix host keys
bootstrap machine ip:
    #!/usr/bin/env bash
    set -euo pipefail

    TEMP=$(mktemp -d)
    trap 'rm -rf "$TEMP"' EXIT

    echo "🔑 Generating new SSH host key for {{ machine }}..."
    mkdir -p "$TEMP/etc/ssh"
    ssh-keygen -t ed25519 -f "$TEMP/etc/ssh/ssh_host_ed25519_key" -N "" -q

    echo "🔑 Extracting age public key..."
    AGE_KEY=$(nix shell nixpkgs#ssh-to-age -c sh -c 'ssh-to-age < "$1"' _ "$TEMP/etc/ssh/ssh_host_ed25519_key.pub")
    echo "🟢 Generated Age Key: $AGE_KEY"

    if grep -q "&host_{{ machine }}" .sops.yaml; then
        sed -E "s/&host_{{ machine }} age[0-9a-z]+/\&host_{{ machine }} $AGE_KEY/" .sops.yaml > .sops.yaml.tmp
        mv .sops.yaml.tmp .sops.yaml
        echo "✅ Updated .sops.yaml automatically."
    else
        echo "⚠️  Anchor &host_{{ machine }} not found in .sops.yaml!"
        echo "Please manually add it and press Enter to continue..."
        read -r
    fi

    if grep -q "environment.persistence" "hosts/{{ machine }}/default.nix" 2>/dev/null; then
        echo "📂 Detected impermanence for {{ machine }}. Moving keys to /persist/etc/ssh..."
        mkdir -p "$TEMP/persist/etc/ssh"
        mv "$TEMP/etc/ssh/"* "$TEMP/persist/etc/ssh/"
        rm -rf "$TEMP/etc"
    fi

    echo "🔄 Re-encrypting secrets.yaml with new keys..."
    sops updatekeys --yes secrets.yaml

    echo "🚀 Running nixos-anywhere..."
    nix run github:nix-community/nixos-anywhere -- --extra-files "$TEMP" --flake ".#{{ machine }}" --target-host "root@{{ ip }}"
