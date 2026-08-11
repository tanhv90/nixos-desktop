# Aggregates every per-tool NixOS module in this directory.
# Replaces snowfall-lib's automatic module discovery.
{
  imports =
    let
      entries = builtins.attrNames (builtins.readDir ./.);
      dirs = builtins.filter (n: n != "default.nix") entries;
    in
    map (n: ./. + "/${n}") dirs;
}
