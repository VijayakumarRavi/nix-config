{ ... }:
{

  imports = [
    ./common.nix
    ./zsh.nix
    ./git.nix
    ./tmux.nix
    ./starship.nix
    ./nvim.nix
  ];

  # specify my home-manager configs
  # home.packages = with pkgs; [  ];

  systemd.user.startServices = "sd-switch";
  home = {
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
    };

    # file.".inputrc".source = ../dotfiles/inputrc;
    #home.file.".config/starship.toml".source = ./dotfiles/starship.toml;

    # Don't change this when you change package input. Leave it alone.
    stateVersion = "22.11";
  };
}
