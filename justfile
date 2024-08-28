default:
  just --list

deploy machine='':
  #!/usr/bin/env sh
  if [ -z "{{machine}}" ]; then
    if command -v darwin-rebuild &> /dev/null 2>&1; then
      darwin-rebuild switch --flake .
    else
      sudo nixos-rebuild switch --fast --flake .
    fi
  elif [ {{machine}} = "nami" ]; then
    nixos-rebuild switch --fast --flake ".#nami" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.0.2" --build-host "vijay@10.0.0.2"
  elif [ {{machine}} = "zoro" ]; then
    nixos-rebuild switch --fast --flake ".#zoro" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.1.101" --build-host "vijay@10.0.1.101"
  elif [ {{machine}} = "usopp" ]; then
    nixos-rebuild switch --fast --flake ".#usopp" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.1.102" --build-host "vijay@10.0.1.102"
  elif [ {{machine}} = "kube" ]; then
    nixos-rebuild switch --fast --flake ".#zoro" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.1.101" --build-host "vijay@10.0.1.101"
    nixos-rebuild switch --fast --flake ".#usopp" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.1.102" --build-host "vijay@10.0.1.102"
  elif [ {{machine}} = "all" ]; then
    nixos-rebuild switch --fast --flake ".#nami" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.0.2" --build-host "vijay@10.0.0.2"
    nixos-rebuild switch --fast --flake ".#zoro" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.1.101" --build-host "vijay@10.0.1.101"
    nixos-rebuild switch --fast --flake ".#usopp" --accept-flake-config --use-remote-sudo --target-host "vijay@10.0.1.102" --build-host "vijay@10.0.1.102"
  fi

up:
  nix flake update

gc:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d && sudo nix store gc

repair:
  sudo nix-store --verify --check-contents --repair

secrets-edit:
  sops secrets.yaml

secrets-rotate:
  sops --rotate --in-place secrets.yaml

secrets-sync:
  sops updatekeys --yes secrets.yaml

iso:
  nix build -L --accept-flake-config .#nixos-iso

pi:
  nix build -L --accept-flake-config .#nixosConfigurations.nami.config.system.build.sdImage --system "aarch64-linux"
