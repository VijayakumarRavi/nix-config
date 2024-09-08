default:
  @just --list --unsorted --list-heading $'Available repo commands\n'

# deploy locally - mention host name to deploy remotely
deploy machine='':
  #!/usr/bin/env sh
  if [ -z "{{machine}}" ]; then
    if command -v darwin-rebuild &> /dev/null 2>&1; then
      darwin-rebuild switch --flake .
    else
      sudo nixos-rebuild switch --fast --flake .
    fi
  elif [ {{machine}} = "nami" ]; then
    @just deploy-nami
  elif [ {{machine}} = "zoro" ]; then
    @just deploy-zoro
  elif [ {{machine}} = "usopp" ]; then
    @just deploy-usopp
  elif [ {{machine}} = "kube" ]; then
    @just deploy-zoro
    @just deploy-usopp
  elif [ {{machine}} = "all" ]; then
    @just deploy-nami
    @just deploy-zoro
    @just deploy-usopp
  fi

# Remote deploy nami
deploy-nami:
    nixos-rebuild switch --fast --flake ".#nami" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.0.2" --build-host "vijay@10.0.0.2"

# Remote deploy zoro
deploy-zoro:
    nixos-rebuild switch --fast --flake ".#zoro" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.1.101" --build-host "vijay@10.0.1.101"

# Remote deploy usopp
deploy-usopp:
    nixos-rebuild switch --fast --flake ".#usopp" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.1.102" --build-host "vijay@10.0.1.102"

# update flake.lock
up:
  nix flake update

# update flake.lock commit it
up-commit:
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

secrets-rotate:
  sops --rotate --in-place secrets.yaml

# update new secrets with new key
secrets-sync:
  sops updatekeys --yes secrets.yaml

# Build nixos install ISO
iso:
  nix build -L .#nixos-iso && attic push system ./result && cachix push vijay ./result

# build SdImage for pi(Nami)
pi-img:
  nix build -L --accept-flake-config .#nixosConfigurations.nami.config.system.build.sdImage --system "aarch64-linux" && attic push system ./result && cachix push vijay ./result

# Build and upload cache to attic for all host
cache:
  #@just up
  @just iso
  @just pi-img
  @just cache-nami
  @just cache-zoro
  @just cache-usopp
  rm ./result

# Build and upload cache to attic for zoro host
cache-zoro:
  nix build -L --accept-flake-config .#nixosConfigurations.zoro.config.system.build.toplevel && attic push system ./result && cachix push vijay ./result

# Build and upload cache to attic for usopp host
cache-usopp:
  nix build -L --accept-flake-config .#nixosConfigurations.usopp.config.system.build.toplevel && attic push system ./result && cachix push vijay ./result

# Build and upload cache to attic for kakashi host
cache-kakashi:
  nix build -L --accept-flake-config .#darwinConfigurations.kakashi.config.system.build.toplevel --system "aarch64-darwin" --impure && attic push system  && cachix push vijay ./result./result

# Build and upload cache to attic for nami host
cache-nami:
  nix build -L --accept-flake-config .#nixosConfigurations.nami.config.system.build.toplevel --system "aarch64-linux" && attic push system ./result && cachix push vijay ./result
