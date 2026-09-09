{
  lib,
  config,
  inputs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.flatpak;
in
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
  options.${namespace}.flatpak = {
    enable = lib.mkEnableOption "Flatpak with declarative package management via nix-flatpak";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Flatpak app refs (Flathub app IDs) installed on activation.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      remotes = lib.mkIf (cfg.packages != [ ]) [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      packages = cfg.packages;
      # Keep declaratively installed Flatpaks updated on `nixos-rebuild switch`.
      update = {
        onActivation = true;
        # Periodic background updates via a persistent systemd timer.
        auto = {
          enable = true;
          onCalendar = "weekly";
        };
      };
    };
  };
}
