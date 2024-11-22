# default_pkgs.nix
_: let
  files = builtins.readDir ./.;

  # Filter out default.nix and non-.nix files from both directories
  nixFiles =
    builtins.filter
    (name: name != "default.nix" && builtins.match ".*\\.nix" name != null)
    (builtins.attrNames files);

  # Create a list of import statements for both directories
  imports = map (name:
    if builtins.elem name (builtins.attrNames files)
    then ./. + "/${name}"
    else null)
  nixFiles;
in {
  # Import all configuration modules automatically
  inherit imports;
}
