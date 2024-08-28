{
  pkgs,
  inputs,
  config,
  variables,
  ...
}: {
  imports = [
    ./common.nix
    ./zsh.nix
    ./git.nix
    ./tmux.nix
    ./starship.nix
    ./nvim
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    secrets = {
      github_oauth_token = {};
      id_ed25519 = {path = "${config.home.homeDirectory}/.ssh/id_ed25519";};
      id_ed25519_pub = {path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";};
    };
  };

  systemd.user.startServices = "sd-switch";
  home = {
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
    };
    file.".config/htop/htoprc".source = ./htoprc;
    # Don't change this when you change package input. Leave it alone.
    inherit (variables) stateVersion;
  };
  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    echo "--- home manager diff to current-system"
    ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff $oldGenPath $newGenPath
    echo "---"
  '';
}
