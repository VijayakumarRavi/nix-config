{
  pkgs,
  config,
  variables,
  ...
}: {
  imports = [
    ./yazi
    ./zsh.nix
    ./git.nix
    ./tmux.nix
    ./common.nix
    ./starship.nix
  ];

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
