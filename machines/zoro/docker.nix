{ ... }: {

  # Enable docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true; # periodically prune Docker resources.
    autoPrune.dates = "daily";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
