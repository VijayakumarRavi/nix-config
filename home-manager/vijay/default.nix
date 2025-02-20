{
  pkgs,
  config,
  #  system,
  variables,
  ...
}: {
  imports = [
    ./yazi
    ./core.nix
    ./htop.nix
    ./zsh.nix
    ./git.nix
    ./k9s.nix
    ./tmux.nix
    ./starship.nix
  ];
  # ++ (
  #   if system == "aarch64-darwin"
  #   then [./kakashi]
  #   else []
  # );

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
  home = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
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
    echo "--- home manager diff to current-system"
    ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff $oldGenPath $newGenPath
    echo "---"
  '';
}
