{
  description = "My configs";
  nixConfig = {
    substituters = [
      "https://nix-community.cachix.org?priority=1"
      "https://numtide.cachix.org?priority=2"
      "https://raspberry-pi-nix.cachix.org?priority=3"
      "https://cache.nixos.org?priority=4"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11

    # Used to generate custom iso installer images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # git pre commit hook
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    #Raspberry pi nix
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs";

    # For M2 Macbook Air
    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";

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

    # Agenix for secrets
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        darwin.follows = "darwin";
      };
    };
  };
  outputs =
    inputs@{ self
    , nixpkgs
    , nixos-generators
    , home-manager
    , darwin
    , nix-homebrew
    , homebrew-bundle
    , homebrew-core
    , homebrew-cask
    , homebrew-services
    , ...
    }:
    let
      # Config
      user = "Vijayakumar Ravi";
      username = "vijay";
      # stateVersion = "24.11";
      # stateVersionDarwin = 4;

      # Configured Hosts
      darwinSystems = { kakashi = "aarch64-darwin"; };
      linuxSystems = {
        zoro = "x86_64-linux";
        usopp = "x86_64-linux";
        choppar = "x86_64-linux";
        kakashi = "aarch64-linux";
      };

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      pre-commit = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            deadnix.enable = true;
            actionlint.enable = true;
            nixpkgs-fmt.enable = true;
            flake-checker.enable = true;
            check-symlinks.enable = true;
            end-of-file-fixer.enable = true;
            detect-private-keys.enable = true;
            trim-trailing-whitespace.enable = true;
            nix-flake-check = {
              enable = true;
              name = "Nix flake check";
              stages = [ "pre-push" ];
              pass_filenames = false;
              entry = "nix flake check --accept-flake-config --all-systems";
            };
          };
        };
      });
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.pre-commit.${system}.pre-commit-check) shellHook;
          buildInputs = self.pre-commit.${system}.pre-commit-check.enabledPackages;
        };
      });
      packages.x86_64-linux = {
        # NixOS boot disk with my SSH Keys integrated
        nixos-iso = nixos-generators.nixosGenerate {
          specialArgs = { inherit inputs username user; };
          system = "x86_64-linux";
          format = "install-iso";
          modules = [
            ./machines/nixiso
          ];
        };
      };
      packages.aarch64-linux = {
        rpi-iso = nixos-generators.nixosGenerate {
          specialArgs = { inherit inputs username user; };
          system = "aarch64-linux";
          format = "sd-aarch64";
          modules = [
            #inputs.raspberry-pi-nix.nixosModules.raspberry-pi
            ./machines/raspberry
          ];
        };
      };
      darwinConfigurations.kakashi = darwin.lib.darwinSystem {
        system = darwinSystems.kakashi;
        # makes all inputs available in imported files
        specialArgs = { inherit inputs username user; };
        modules = [
          ./machines/kakashi
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = user;
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
              extraSpecialArgs = { inherit inputs username user; };
              users.${username}.imports = [ ./home-manager/kakashi ];
            };
          }
        ];
      };

      nixosConfigurations = builtins.listToAttrs (map
        (name: {
          inherit name;
          value = nixpkgs.lib.nixosSystem
            {
              # makes all inputs available in imported files
              specialArgs = {
                inherit inputs username user;
                meta = { hostname = name; };
              };
              system = linuxSystems.${name};
              modules = [
                home-manager.nixosModules.home-manager
                {
                  home-manager.extraSpecialArgs = { inherit inputs username user; };
                  home-manager.users.${username} = {
                    imports = if name == "kakashi" then [ ./home-manager/kakashi-nix ] else [ ./home-manager/kubenodes ];
                  };
                }
              ] ++ (if name == "kakashi" then [ ./machines/kakashi-nix ] else [ ./machines/kubenodes ]);
            };
        }) [ "zoro" "usopp" "choppar" "kakashi" ]);
    };
}
