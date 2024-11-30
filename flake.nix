{
  description = "Vijay's NixOS & MacOS Configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://vijay.cachix.org"
      "https://numtide.cachix.org"
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "vijay.cachix.org-1:6Re6EF3Q58sxaIobAWP1QTwMUCSA0nYMrSJGUedL3Zk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    # Core NixOS repo
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Index for faster package search
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Home manager config
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # System-level config for MacOS
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Disk partition management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Git pre-commit hooks
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim config
    nvim.url = "github:vijayakumarravi/vjvim";
    nvim.inputs.nixpkgs.follows = "nixpkgs";
    nvim.inputs.pre-commit-hooks.follows = "pre-commit-hooks";

    # Raspberry Pi support
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix/v0.4.1";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets management with sops
    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Firefox nightly build flake
    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew configuration
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-services.url = "github:homebrew/homebrew-services";

    # Disable flakes for some Homebrew inputs
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";
    homebrew-bundle.flake = false;
    homebrew-core.flake = false;
    homebrew-cask.flake = false;
    homebrew-services.flake = false;
  };

  outputs = inputs @ {
    darwin,
    nixpkgs,
    home-manager,
    ...
  }: let
    # Configuration variables
    variables = {
      username = "vijay";
      user = "Vijayakumar Ravi";
      useremail = "im@vijayakumar.xyz";
      stateVersion = "24.11";
      stateVersionDarwin = 4;
    };

    # Supported systems for NixOS and MacOS
    supportedSystems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Pre-commit hooks configuration for all systems
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

    # Helper to create a system configuration
    mkSystem = configurations: system: hostname:
      configurations {
        inherit system;
        # Pass all relevant inputs and variables to imported files
        specialArgs = {inherit inputs variables hostname;};
        modules = [
          ./machines/${hostname}
          (
            if system == "aarch64-darwin"
            then home-manager.darwinModules.home-manager
            else home-manager.nixosModules.home-manager
          )
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {inherit inputs variables;};
              users.${variables.username}.imports = [./home-manager/${hostname}];
            };
          }
        ];
      };
  in {
    # Formatter configuration for all systems
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Development shell with pre-commit hooks
    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (pre-commit.${system}.pre-commit-check) shellHook;
        buildInputs = with nixpkgs.legacyPackages.${system}; [nixos-rebuild] ++ pre-commit.${system}.pre-commit-check.enabledPackages;
      };
    });

    # NixOS system configurations
    nixosConfigurations = {
      zoro = mkSystem nixpkgs.lib.nixosSystem "x86_64-linux" "zoro";
      usopp = mkSystem nixpkgs.lib.nixosSystem "x86_64-linux" "usopp";
      chopper = mkSystem nixpkgs.lib.nixosSystem "x86_64-linux" "chopper";
      nixiso = mkSystem nixpkgs.lib.nixosSystem "x86_64-linux" "nixiso";
      nami = mkSystem nixpkgs.lib.nixosSystem "aarch64-linux" "nami";
    };

    # MacOS configurations
    darwinConfigurations = {
      kakashi = mkSystem darwin.lib.darwinSystem "aarch64-darwin" "kakashi";
    };
  };
}
