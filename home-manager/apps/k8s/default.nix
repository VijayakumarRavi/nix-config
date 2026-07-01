{
  pkgs,
  inputs,
  ...
}: {
  imports = [./k9s.nix];

  home.packages = with pkgs; [
    # Containers & Kubernetes
    kind # local clusters for testing Kubernetes
    fluxcd # Kubernetes GitOps
    kubectl # Kubernetes CLI tool
    kubectx # Switch faster between clusters and namespaces in kubectl
    kubetail # Bash script to tail Kubernetes logs from multiple pods at the same time
    talosctl # Talosctl is a command line tool for interacting with Talos clusters
    helmfile # Deploy Kubernetes Helm Charts
    opentofu # terraform open source alternative
    kustomize # Customization of kubernetes YAML configurations
    kubeconform # Kubernetes manifests validator
    lazydocker # A simple terminal UI for both docker and docker-compose
    kubernetes-helm # A package manager for kubernetes
    inputs.talhelper.packages.${pkgs.stdenv.hostPlatform.system}.default # A tool to help creating Talos kubernetes cluster
  ];
}
