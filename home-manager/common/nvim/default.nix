{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ./config;
    recursive = true;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  home.packages = with pkgs; [
    # nvim deps
    statix # Lints and suggestions for the Nix programming language.
    codespell # Fix common misspellings in source code
    stylua # An opinionated Lua code form matter
    nil # Yet another language server for Nix
    alejandra # formatter for Nix
    ripgrep # for telescope builtin.grep_string function
  ];
}
