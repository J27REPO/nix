{ pkgs, user, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  
  boot.kernelParams = [ "snd_hda_intel.model=apple-headset-multi" ];
  boot.kernelModules = [ "uinput" ];

  services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess", GROUP="input", MODE="0660"
    '';
    
  # 1. Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.interfaces.enp1s0.wakeOnLan = {
      enable = true;
      policy = [ "magic" ];
    };
  
    # 2. Instalar ethtool para comprobar que todo está bien
    environment.systemPackages = [ pkgs.ethtool ];
  # 2. Drivers Gráficos Intel (Específico Mac Mini)
  services.xserver.videoDrivers = [ "intel" ]; 
  hardware.graphics.enable = true;

  # --- NUEVA CONFIGURACIÓN PARA ACCESO REMOTO ---

  # 3. Habilitar SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true; # Permite entrar con tu contraseña
      PermitRootLogin = "no";        # Seguridad: no permite entrar como root
    };
  };

  # 4. Habilitar Tailscale
  services.tailscale.enable = true;
  networking.hostName = "macmini";
  services.resolved.enable = true;
  # 5. Configurar Firewall para Tailscale y SSH
  networking.firewall = {
    enable = true;
    # "loose" es necesario para que Tailscale atraviese el firewall correctamente
    checkReversePath = "loose"; 
    allowedUDPPorts = [ 41641 ]; # Puerto oficial de Tailscale
    allowedTCPPorts = [ 22 ];    # Puerto estándar de SSH
  };
  services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # Necesario para crear dispositivos de entrada virtuales
      openFirewall = true; # Abre los puertos 47984-48010
    };

  # ----------------------------------------------

  # 6. Definición de Usuario
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ]; # He añadido docker por si lo usas
  };
}
