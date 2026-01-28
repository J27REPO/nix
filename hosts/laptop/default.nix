{ pkgs, user, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  # --- NETWORKING & HOSTNAME ---
  networking.hostName = "laptop"; 
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd"; # Motor de iwd para Impala
  networking.wireless.iwd.enable = true;          # Activar servicio iwd

  # --- ACCESO REMOTO (SSH & VPN) ---
  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  networking.firewall = {
    enable = true;
    checkReversePath = "loose"; 
    allowedUDPPorts = [ 41641 ]; 
    allowedTCPPorts = [ 22 ];    
  };

  # --- BOOTLOADER ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- GRÁFICOS (AMD Específico Laptop) ---
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = { 
    enable = true; 
    enable32Bit = true; 
  };

  # --- TIPOGRAFÍAS ---
  fonts = {
    fontconfig = {
      antialias = true;
      hinting.enable = true;
    };
  };

  # --- CONFIGURACIÓN DE USUARIO ---
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ]; 
  };

  # --- VARIABLES DE ENTORNO ---
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; 
  };
  
  # El paquete 'moonlight-qt' debe ir en tu nix/home/default.nix.
}
