{
  ...
}:

final: prev:
{
  opencode = prev.opencode.overrideAttrs (old: rec {
    version = "1.17.0";
    src = prev.fetchFromGitHub {
      owner = "anomalyco";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-3JxIc7I5uNswGyaPa+MTGdNWCU4p3CFm+8/bICh0jsA=";
    };
    node_modules = old.node_modules.overrideAttrs (_: {
      inherit version src;
      outputHash = "sha256-oHy+WKRPAxHbiAOHj0wrllXG297dcfQQw8gR1ds9Ano=";
    });
  });
}
