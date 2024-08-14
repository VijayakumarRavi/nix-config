{ lib, ... }: {
  # vjvim,
  imports = [
    ../common
    # ./firefox.nix
  ];
  # file.".kube/config".source = /etc/rancher/k3s/k3s.yaml;
  home.activation = {
    cubeconfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir ~/.kube && cp -f /etc/rancher/k3s/k3s.yaml ~/.kube/config
    '';
  };
}
