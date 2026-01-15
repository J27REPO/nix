{ pkgs, user, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  # 1. Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 2. Drivers Gráficos Intel (Específico Mac Mini)
  # Usamos 'modesetting' que suele ir mejor en Intel modernos/medios que el driver 'intel' antiguo
  services.xserver.videoDrivers = [ "modesetting" ]; 
  hardware.graphics.enable = true;

  # 3. Habilitar Hyprland a nivel sistema
  # (Necesario para que aparezca en el login, aunque la config visual esté en Home Manager)
  programs.hyprland.enable = true;

  # 4. Definición de Usuario (Para que no tengas que crearlo manual)
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };
  
  # Nota sobre el Monitor (DP-1):
  # Al usar una config compartida en Home Manager, Hyprland intentará detectar
  # el monitor automáticamente ("auto"). Si ves que no te da la resolución correcta,
  # avísame y añadiremos una condición específica para el Mac Mini.
}
