{
  description = "Kakashi config";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11

    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Tricked out nvim
    vjvim.url = "github:VijayakumarRavi/vjvim";
  };
  outputs = inputs@{ nixpkgs, home-manager, darwin, vjvim, ... }: {
    darwinConfigurations = {
      Kakashi = darwin.lib.darwinSystem {
            pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
        system = "aarch64-darwin";
        modules = [
            ./hosts/kakashi
            home-manager.darwinModules.home-manager {
            users.users.vijay.home = /Users/vijay;
            home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit vjvim; };
            users.vijay.imports = [ ./home-manager ];
            };
          }
        ];
      };
    };
  };
}
