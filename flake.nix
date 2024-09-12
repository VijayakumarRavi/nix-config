{
  description = "My configs";
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://vijay.cachix.org"
      "https://numtide.cachix.org"
      "https://nix-community.cachix.org"
      # "https://atticcache.fly.dev/system"
    ];

    extra-trusted-public-keys = [
      "vijay.cachix.org-1:6Re6EF3Q58sxaIobAWP1QTwMUCSA0nYMrSJGUedL3Zk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      # "system:gzdIUkeQT1/YeohwHOQGWv3T975iWVwOxAXemBOxL24="
    ];
  };
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11

    # Used to generate custom iso installer images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # nix packages index to find it faster
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

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

    # secrets management
    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";

    # My custom suckless build
    suckless.url = "github:VijayakumarRavi/suckless";
    suckless.inputs.nixpkgs.follows = "nixpkgs";

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
  outputs = inputs @ {
    darwin,
    nixpkgs,
    suckless,
    home-manager,
    nix-index-database,
    ...
  }: let
    # Config
    variables = {
      username = "vijay";
      user = "Vijayakumar Ravi";
      useremail = "im@vijayakumar.xyz";
      stateVersion = "24.11";
      stateVersionDarwin = 4;
    };
    # Configured Hosts
    darwinSystems = {kakashi = "aarch64-darwin";};
    linuxSystems = {
      nami = "aarch64-linux";
      zoro = "x86_64-linux";
      usopp = "x86_64-linux";
      choppar = "x86_64-linux";
      nixiso = "x86_64-linux";
    };

    supportedSystems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    pre-commit = forAllSystems (system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          actionlint.enable = true;
          shellcheck.enable = true;
          flake-checker.enable = true;
          check-symlinks.enable = true;
          end-of-file-fixer.enable = true;
          detect-private-keys.enable = true;
          trim-trailing-whitespace.enable = true;
          trim-trailing-whitespace.stages = ["pre-commit"];
          deadnix = {
            enable = true;
            settings = {
              edit = true;
              noLambdaArg = true;
            };
          };
          just = {
            enable = true;
            files = "justfile";
            name = "just-fmt";
            pass_filenames = false;
            entry = "just --fmt --unstable";
          };
          statix = {
            enable = true;
            files = "\\.nix$";
            name = "statix-fix";
            entry = "statix fix";
          };
          git-pull = {
            enable = true;
            name = "git-pull-remort";
            always_run = true;
            pass_filenames = false;
            stages = ["post-commit"];
            entry = "git pull --rebase --quiet --autostash";
          };
          nix-flake-check = {
            enable = true;
            name = "nix-flake-check";
            files = "\\.nix$";
            stages = ["pre-push"];
            pass_filenames = false;
            entry = "nix flake check --accept-flake-config --all-systems";
          };
        };
      };
    });
  in {
    # Enables `nix fmt` at root of repo to format all nix files
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # devShell to enable pre-commit via direnv
    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (pre-commit.${system}.pre-commit-check) shellHook;
        buildInputs = with nixpkgs.legacyPackages.${system}; [just nixos-rebuild] ++ pre-commit.${system}.pre-commit-check.enabledPackages;
      };
    });

    # NixOS boot disk with my SSH Keys integrated
    # packages = forAllSystems (system: {
    #   nixos-iso = nixos-generators.nixosGenerate {
    #     specialArgs = {inherit inputs variables;};
    #     inherit system;
    #     format = "install-iso";
    #     modules = [
    #       ./machines/nixiso
    #     ];
    #   };
    # });

    # Macos configurations
    darwinConfigurations.kakashi = darwin.lib.darwinSystem {
      system = darwinSystems.kakashi;
      # makes all inputs & variables available in imported files
      specialArgs = {inherit inputs variables;};
      modules = [
        ./machines/kakashi
        nix-index-database.darwinModules.nix-index
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {inherit inputs variables;};
            users.${variables.username}.imports = [./home-manager/kakashi];
          };
        }
      ];
    };

    nixosConfigurations = builtins.listToAttrs (map
      (name: {
        inherit name;
        value =
          nixpkgs.lib.nixosSystem
          {
            # makes all inputs & variables available in imported files
            specialArgs = {
              inherit inputs variables suckless;
              meta = {hostname = name;};
            };
            system = linuxSystems.${name};
            modules =
              [
                nix-index-database.nixosModules.nix-index
                home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    backupFileExtension = "backup";
                    extraSpecialArgs = {inherit inputs variables;};
                    users.${variables.username} = {
                      imports =
                        if name == "nami"
                        then [./home-manager/nami]
                        else [./home-manager/kubenodes];
                    };
                  };
                }
              ]
              ++ (
                if name == "nami"
                then [./machines/nami]
                else if name == "nixiso"
                then [./machines/nixiso]
                else [./machines/kubenodes]
              );
          };
      }) ["zoro" "usopp" "choppar" "nami" "nixiso"]);
  };
}
