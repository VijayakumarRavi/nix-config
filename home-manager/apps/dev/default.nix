{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Dev utils & languages
    jq # JSON query tool
    yq # jq wrapper for YAML
    go
    gcc # c compiler
    tree # Tree command line tool
    just # Command runner
    yarn
    cmake
    iperf # Network performance test
    cachix # Command-line client for Nix binary cache hosting https://cachix.org
    go-task
    python3 # Python lang
    unixtools.watch # Watch command line tool
    pre-commit # Tool to manage pre-commit hooks
    python3Packages.pip # install python dependencies
  ];
}
