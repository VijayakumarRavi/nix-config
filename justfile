default:
  just --list

deploy machine ip='':
  #!/usr/bin/env sh
  if [ {{machine}} = "kakashi" ]; then
    darwin-rebuild switch --flake .
  elif [ -z "{{ip}}" ]; then
    sudo nixos-rebuild switch --fast --flake ".#{{machine}}"
  else
    nixos-rebuild switch --fast --flake ".#{{machine}}" --use-remote-sudo --target-host "vijay@{{ip}}" --build-host "vijay@{{ip}}"
  fi

up:
  nix flake update

gc:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d && sudo nix store gc

repair:
  sudo nix-store --verify --check-contents --repair

secrets-edit:
  sops secrets/secrets.yaml

secrets-rotate:
  for file in secrets/*; do sops --rotate --in-place "$file"; done

secrets-sync:
  for file in secrets/*; do sops updatekeys "$file"; done

build-iso:
  nix build -L --accept-flake-config .#nixos-iso

build-pi:
  nix build -L --accept-flake-config .#nixosConfigurations.nami.config.system.build.sdImage --system "aarch64-linux"
