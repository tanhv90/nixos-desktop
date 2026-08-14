{
  description = "kbb's Desktop NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    fcitx5-lotus = {
      url = "github:LotusInputMethod/fcitx5-lotus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      # Module namespace — modules/{nixos,home}/* open options under
      # config.${namespace}.<name> (previously handled by snowfall-lib).
      namespace = "kbb";
    in
    {
      nixosConfigurations.Desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs namespace;
        };
        modules = [
          ./systems/x86_64-linux/Desktop
          ./modules/nixos

          { nixpkgs.config.allowUnfree = true; }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # Auto-load every modules/home/* module into the user config,
              # mirroring snowfall-lib's module discovery.
              sharedModules = [
                ./modules/home
              ];
              users.kbb = import ./homes/x86_64-linux/${"kbb@Desktop"};
              extraSpecialArgs = {
                inherit inputs namespace;
              };
            };
          }
        ];
      };
    };
}
