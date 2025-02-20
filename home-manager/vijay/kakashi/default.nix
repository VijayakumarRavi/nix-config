{pkgs, ...}: {
  imports = [
    ../core
    ./kitty.nix
    ./wezterm.nix
    ./alacritty.nix
    ./aerospace.nix
  ];

  programs = {
    gh = {
      enable = true; # GitHub CLI
      extensions = with pkgs; [gh-markdown-preview];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
