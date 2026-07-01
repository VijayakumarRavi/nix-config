{pkgs, ...}: {
  imports = [
    ../common
    ../apps/dev
    ../apps/k8s
    ../apps/terminals/kitty.nix
    ../apps/terminals/wezterm.nix
    ../apps/terminals/alacritty.nix
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
