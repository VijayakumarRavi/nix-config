{
  imports = [
    ./common.nix
    ./zsh.nix
    ./git.nix
    ./tmux.nix
    ./starship.nix
    ./nvim.nix
  ];

  systemd.user.startServices = "sd-switch";
  home = {
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
    };
    # Don't change this when you change package input. Leave it alone.
    stateVersion = "22.11";
  };
}
