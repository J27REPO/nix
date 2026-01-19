{
  description = "NixOS Config - J27";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    autofirma-nix.url = "github:nix-community/autofirma-nix";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      user = "j27";
      
      # Función modificada para aceptar argumentos de teclado y monitor
      mkHost = hostname: kbLayout: kbOptions: monitorConfig: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs user; 
          # Pasamos las variables de teclado y monitor a todo el sistema
          inherit kbLayout kbOptions monitorConfig;
        };
        modules = [
          ./modules/core.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs user kbLayout kbOptions monitorConfig hostname; };
            home-manager.users.${user} = import ./home/default.nix;
          }
          ./hosts/${hostname}/default.nix
          { networking.hostName = hostname; }
        ];
      };
    in
    {
      nixosConfigurations = {
        # Laptop: Español, monitor automático a escala 1
        laptop = mkHost "laptop" "es" "" ",preferred,auto,1";

        # Mac Mini: Inglés (US), Monitor preferido automático
        macmini = mkHost "macmini" "us" "altwin:swap_lalt_lwin,compose:caps" ",preferred,auto,1";
      };
    };
}
