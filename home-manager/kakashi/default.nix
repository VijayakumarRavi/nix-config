{pkgs, ...}: {
  imports = [
    ../common
    ./lf.nix
    ./wezterm.nix
    #./alacritty.nix
    ./wezterm.nix
    ./lf.nix
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
