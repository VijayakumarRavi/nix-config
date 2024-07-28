{ ... }:
{
  imports = [
    ../common
    ./lf.nix
    ./wezterm.nix
    #./alacritty.nix
    ./wezterm.nix
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    gh = {
      enable = true; # GitHub CLI
      extensions = with pkgs; [ gh-markdown-preview ];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
