{
  description = "NixOS Config - J27";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    autofirma-nix.url = "github:nix-community/autofirma-nix";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    
    # NvChad para Neovim
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rustnet = {
      url = "github:domcyrus/rustnet/v1.3.0";
      flake = false;
    };

    # Formateo y linting de código Nix
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, treefmt-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      user = "j27";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Función modificada para aceptar argumentos de teclado y monitor
      mkHost = hostname: kbLayout: kbVariant: kbOptions: monitorConfig: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs user; 
          # Pasamos las variables de teclado y monitor a todo el sistema
          inherit kbLayout kbVariant kbOptions monitorConfig;
        };
        modules = [
          ./modules/core.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs user kbLayout kbVariant kbOptions monitorConfig hostname; };
            home-manager.users.${user} = import ./home/default.nix;
          }
          ./hosts/${hostname}/default.nix
          { networking.hostName = hostname; }
        ];
      };
    in
    {
      packages.x86_64-linux.rustnet = pkgs.callPackage ./pkgs/rustnet.nix {
        src = inputs.rustnet;
        clang = pkgs.llvmPackages.clang-unwrapped;
      };

      # --- Formateo y linting: `nix fmt` y `nix flake check` ---
      formatter.x86_64-linux = treefmt-nix.lib.x86_64-linux.mkWrapper {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          statix.enable = true;
        };
      };

      nixosConfigurations = {
        # Laptop: Español, sin variante, monitor automático a escala 1
        laptop = mkHost "laptop" "es" "" "" ",preferred,auto,1";

        # Mac Mini: US International (dead keys) — ´+a=á, `+a=à, ~+n=ñ, sin compose
        macmini = mkHost "macmini" "us" "intl" "" "DP-1,1920x1080@120,auto,1";

        # Disco SSD externo: Español, genérico (se adapta a cualquier hardware)
        disco = mkHost "disco" "es" "" "" "preferred,auto,1";
      };
    };
}
