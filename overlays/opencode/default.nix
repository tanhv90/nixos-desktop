{
  ...
}:

final: prev:
{
  opencode = prev.opencode.overrideAttrs (old: rec {
    version = "1.17.7";
    src = prev.fetchFromGitHub {
      owner = "anomalyco";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-rTeJuwqc11r6Xiksfg5IoTezK2ZtG3GlenQCxTW04P4=";
    };
    node_modules = old.node_modules.overrideAttrs (_: {
      inherit version src;
      outputHash = "sha256-DntnRo2N32nhjv8YxedIbRMtEkSsXAOrpFmK6six/g4=";
    });
  });
}
