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

    # herdr's own lock pins an old rust-overlay (2026-07-09) whose
    # mk-aggregated.nix still reads the deprecated stdenv.isLinux/isDarwin
    # aliases. Override it with a direct input so `nix flake update` also
    # updates it (upstream fixed this on 2026-08-13 in 892c035).
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    # Not in nixpkgs: Mandara ships only as this flake. Its nixpkgs input is
    # deliberately not followed — the package we install is the one its own
    # lock builds, which is what mandara.cachix.org has prebuilt. Following
    # our nixpkgs would compile the whole Rust shell from source.
    mandara.url = "github:theHamdiz/mandara";
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

          {
            nixpkgs.config = {
              allowUnfree = true;
              # onlyoffice-desktopeditors still lists gtk2 in buildInputs in nixpkgs
              # (https://github.com/NixOS/nixpkgs/issues/410814)
              problems.handlers."gtk+".broken = "warn";
            };
          }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # Auto-load every modules/home/* module into the user config,
              # mirroring snowfall-lib's module discovery.
              sharedModules = [
                ./modules/home
                inputs.mandara.homeManagerModules.default
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
