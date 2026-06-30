default:
    just --list --unsorted --list-heading $'Available repo commands\n'

# Remote deploy zoro
deploy-zoro:
    nixos-rebuild switch --no-reexec -L --flake ".#zoro" --accept-flake-config --elevate=sudo --target-host "vijay@10.0.2.200"
deploy-robin:
    nixos-rebuild switch --no-reexec -L --flake ".#robin" --accept-flake-config --elevate=sudo --target-host "vijay@robin"

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

# Bootstrap a new NixOS machine using nixos-anywhere, automatically handling sops-nix host keys
bootstrap machine ip options='--build-on local':
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
    nix run github:nix-community/nixos-anywhere -- --extra-files "$TEMP" --flake ".#{{ machine }}" --target-host "root@{{ ip }}" {{ options }}
