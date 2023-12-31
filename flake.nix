{
  description = "My configs";
  nixConfig = {
    substituters = [
      "https://vjvim.cachix.org?priority=1"
      "https://nix-community.cachix.org?priority=2"
      "https://numtide.cachix.org?priority=3"
      "https://cache.nixos.org?priority=4"
    ];

    trusted-public-keys = [
      "vjvim.cachix.org-1:AF3grdItpExuZ95D16gb7DN/9kYhf91OwZoNBCfHW98="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
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

    # Sops secrets encryption
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware config
    hw-config = {
      url = "/etc/nixos";
      flake = false;
    };

    # Firefox extensions support
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ nixpkgs, home-manager, darwin, vjvim, ... }: {
    darwinConfigurations.kakashi = darwin.lib.darwinSystem {
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
      system = "aarch64-darwin";
      # makes all inputs availble in imported files
      specialArgs = {inherit inputs;};
      modules = [
        ./machines/kakashi
          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit vjvim; };
              users.vijay.imports = [ ./home-manager/kakashi ];
            };
          }
      ];
    };

    nixosConfigurations.zoro = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # makes all inputs availble in imported files
      specialArgs = {inherit inputs;};
      modules = [
        ./machines/zoro
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit vjvim; inherit inputs; };
            home-manager.users.vijay = {...}: {
              imports = [./home-manager/zoro ];
            };
          }
      ];
    };
  };
}
