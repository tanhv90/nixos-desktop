{
  ...
}:

final: prev:
{
  opencode = prev.opencode.overrideAttrs (old: rec {
    version = "1.17.18";
    src = prev.fetchFromGitHub {
      owner = "anomalyco";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-Y0rcO6r9yqhYux8IS5oAtgzcMXfJE8I1Lre4HdJ5nBg=";
    };
    node_modules = old.node_modules.overrideAttrs (_: {
      inherit version src;
      outputHash = "sha256-kXdXw264JQdlNoZPv5GUyWZvb/A8h2CTRdiX79jyvys=";
    });
  });
}
