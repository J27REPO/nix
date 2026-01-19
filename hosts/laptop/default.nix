{ pkgs, user, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = { enable = true; enable32Bit = true; };

  fonts = {
    fontconfig = {
      antialias = true;
      hinting.enable = true;
    };
  };

  # Habilitar el programa Hyprland a nivel sistema (Login manager, binarios)
  # PERO la config visual está ahora en Home Manager
  

  # Usuario
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  # Configuración de Monitor Específica (Solo esto queda aquí)
  # Se inyecta antes de que cargue la config de usuario
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # A veces ayuda
  };
  
  # Nota: Con Home Manager, la gestión de monitores es mejor hacerla con 
  # herramientas como 'wlr-randr' o configurando hyprland.settings.monitor 
  # condicionalmente, pero para simplificar, déjalo auto o configúralo post-arranque.
}
