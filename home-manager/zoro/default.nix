{ pkgs, vjvim, ... }: {
  imports = [
  ../common
  ];
   home.packages = with pkgs; [
      vjvim.packages."x86_64-linux".default
  ];
}
