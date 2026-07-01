{lib, ...}: {
  imports = [
    ../common
    ../apps/k8s
  ];
  # file.".kube/config".source = /etc/rancher/k3s/k3s.yaml;
  home.activation = {
    cubeconfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir ~/.kube && cp -f /etc/rancher/k3s/k3s.yaml ~/.kube/config
    '';
  };
}
