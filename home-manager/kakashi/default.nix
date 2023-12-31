{ pkgs, vjvim, ... }: {
  imports = [ ../common ];
  home.packages = with pkgs; [ vjvim.packages."aarch64-darwin".default ];
}
