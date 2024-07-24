{ pkgs, ... }: { # vjvim,

  home.file.".config/nvim" = {
    source = ../dotfiles/nvim;
    recursive = true;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      # nvim deps
      statix # Lints and suggestions for the Nix programming language.
      codespell # Fix common misspellings in source code
      stylua # An opinionated Lua code form matter
    ];
  };
}
