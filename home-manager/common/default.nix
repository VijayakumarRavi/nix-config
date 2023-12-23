{ pkgs, vjvim, ... }: {

  imports = [
    ./common.nix
    ./zsh.nix
    ./git.nix
    ./tmux.nix
    ./starship.nix
    ./alacritty.nix
    
  ];

  # specify my home-manager configs
  home.packages = with pkgs; [
    fd
    curl
    less
    cachix
    vjvim.packages."aarch64-darwin".default
  ];
  
  systemd.user.startServices = "sd-switch";
  home.sessionPath = ["$HOME/.local/bin"];
  home.sessionVariables = {
    PAGER = "less";
    CLICLOLOR = 1;
    EDITOR = "nvim";
  };

  #  programs.alacritty = {
  #    enable = true;
  #    settings.font.normal.family = "MesloLGS Nerd Font Mono";
  #    settings.font.size = 16;
  #  };

  home.file.".inputrc".source = ../dotfiles/inputrc;
  #home.file.".config/starship.toml".source = ./dotfiles/starship.toml;

  # Don't change this when you change package input. Leave it alone.
  home.stateVersion = "22.11";
}
