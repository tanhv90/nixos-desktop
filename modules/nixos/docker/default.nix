{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.docker;
in
{
  options.${namespace}.docker = {
    enable = lib.mkEnableOption "Docker with NVIDIA GPU support";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      daemon.settings.features.cdi = true;
    };
    hardware.nvidia-container-toolkit.enable = true;
  };
}
