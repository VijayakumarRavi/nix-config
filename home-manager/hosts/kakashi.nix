{pkgs, ...}: {
  imports = [
    ../common
    ../common/terminals/kitty.nix
    ../common/terminals/wezterm.nix
    ../common/terminals/alacritty.nix
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
