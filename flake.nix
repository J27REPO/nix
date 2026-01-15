{
  description = "NixOS Config - J27";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      user = "j27";
      
      # Función modificada para aceptar argumentos de teclado
      mkHost = hostname: kbLayout: kbOptions: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs user; 
          # Pasamos las variables de teclado a todo el sistema
          inherit kbLayout kbOptions;
        };
        modules = [
          ./modules/core.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs user kbLayout kbOptions; };
            home-manager.users.${user} = import ./home/default.nix;
          }
          ./hosts/${hostname}/default.nix
          { networking.hostName = hostname; }
        ];
      };
    in
    {
      nixosConfigurations = {
        # Laptop: Español, sin opciones raras
        laptop = mkHost "laptop" "es" "";

        # Mac Mini: Inglés (US), Alt/Win intercambiados, CapsLock es Compose
        macmini = mkHost "macmini" "us" "altwin:swap_lalt_lwin,caps:compose";
      };
    };
}
