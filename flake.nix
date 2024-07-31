{
  description = "My configs";
  nixConfig = {
    substituters = [
      "https://nix-community.cachix.org?priority=1"
      "https://numtide.cachix.org?priority=2"
      "https://cache.nixos.org?priority=3"
    ];

    trusted-public-keys = [
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

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;

    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    homebrew-services.url = "github:homebrew/homebrew-services";
    homebrew-services.flake = false;
  };
  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      darwin,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      homebrew-services,
      ...
    }:
    {
      darwinConfigurations.kakashi = darwin.lib.darwinSystem {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        system = "aarch64-darwin";
        # makes all inputs available in imported files
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./machines/kakashi
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = "vijay";
              enableRosetta = true;
              autoMigrate = true;
              mutableTaps = false;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "homebrew/homebrew-services" = homebrew-services;
              };
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
              };
              users.vijay.imports = [ ./home-manager/kakashi ];
            };
          }
        ];
      };

      nixosConfigurations = builtins.listToAttrs (
        map
          (name: {
            inherit name;
            value = nixpkgs.lib.nixosSystem {
              # makes all inputs available in imported files
              specialArgs = {
                inherit inputs;
                meta = {
                  hostname = name;
                };
              };
              system = "x86_64-linux";
              modules = [
                ./machines/kubenodes
                # { _module.args.mode = "zap_create_mount"; } #Disko config
                home-manager.nixosModules.home-manager
                {
                  home-manager.extraSpecialArgs = {
                    inherit inputs;
                  };
                  home-manager.users.vijay = {
                    imports = [ ./home-manager/kubenodes ];
                  };
                }
              ];
            };
          })
          [
            "zoro"
            "usopp"
            "choppar"
          ]
      );
    };
}
