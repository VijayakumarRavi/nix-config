# default_pkgs.nix
{pkgs, ...}: {
  # Add the commit package to systemPackages
  environment.systemPackages = [
    (import ./commit.nix {inherit pkgs;})
  ];
}
