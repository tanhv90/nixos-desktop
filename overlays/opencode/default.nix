{
  ...
}:

final: prev:
{
  opencode = prev.opencode.overrideAttrs (old: rec {
    version = "1.17.13";
    src = prev.fetchFromGitHub {
      owner = "anomalyco";
      repo = "opencode";
      tag = "v${version}";
      hash = "sha256-WE8+O+Od8M71fKoOOhE9CbTsJ0JMAi0ZajmYd//VG2k=";
    };
    node_modules = old.node_modules.overrideAttrs (_: {
      inherit version src;
      outputHash = "sha256-SUNfdHtASPh1mpxKvIKJ2GrDHAxmv7Gu7B7vr3PX5W4=";
    });
  });
}
