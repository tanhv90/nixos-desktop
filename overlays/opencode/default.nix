{
  ...
}:

final: prev:
{
  opencode = prev.opencode.overrideAttrs (old: rec {
    version = "1.18.3";
    src = prev.fetchFromGitHub {
      owner = "anomalyco";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-Wdkzms59oHw3M/Em2RH7BPhZME8AtLmtNFSnsUxO1V4=";
    };
    node_modules = old.node_modules.overrideAttrs (_: {
      inherit version src;
      outputHash = "sha256-1NUtprMH8GnSUqQ+mHQSC+JLU7lwzHe6XXYHe129WmE=";
    });
  });
}
