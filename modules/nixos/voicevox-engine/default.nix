{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.voicevox-engine;
in
{
  options.${namespace}.voicevox-engine = {
    enable = lib.mkEnableOption "VOICEVOX speech synthesis engine (GPU, Docker)";

    image = lib.mkOption {
      type = lib.types.str;
      default = "voicevox/voicevox_engine:nvidia-latest";
      description = "Container image. Use a digest pin (image@sha256:…) for reproducibility.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 50021;
      description = "Host port for the API (bound to 127.0.0.1).";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.${namespace}.docker.enable;
        message = "kbb.voicevox-engine requires kbb.docker.enable = true (for nvidia-container-toolkit).";
      }
    ];

    virtualisation.oci-containers = {
      backend = "docker";
      containers.voicevox-engine = {
        image = cfg.image;
        ports = [ "127.0.0.1:${toString cfg.port}:50021" ];
        extraOptions = [ "--gpus=all" ];
        autoStart = true;
      };
    };
  };
}
