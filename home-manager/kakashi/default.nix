{pkgs, ...}: {
  imports = [
    ../common
    ./kitty.nix
    ./wezterm.nix
    ./alacritty.nix
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
