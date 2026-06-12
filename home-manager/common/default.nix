{
  pkgs,
  config,
  variables,
  ...
}: {
  imports = [
    ./core.nix
    ./programs/yazi.nix
    ./programs/htop.nix
    ./programs/git.nix
    ./programs/k9s.nix
    ./programs/tmux.nix
    ./shell/zsh.nix
    ./shell/starship.nix
  ];

  systemd.user.startServices = "sd-switch";
  home = {
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
    };
    # Don't change this when you change package input. Leave it alone.
    inherit (variables) stateVersion;
  };
  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    if [[ -n "''${oldGenPath:-}" ]] && [[ -e "''${oldGenPath:-}" ]]; then
      echo "--- home manager diff to current-system"
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff $oldGenPath $newGenPath
      echo "---"
    fi
  '';
}
