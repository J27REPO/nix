{ pkgs, user, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  # --- NETWORKING & HOSTNAME ---
  networking.hostName = "laptop"; # Nombre para reconocerla en Tailscale/MagicDNS
  networking.networkmanager.enable = true;

  # --- ACCESO REMOTO (SSH & VPN) ---
  # Habilitar Tailscale
  services.tailscale.enable = true;

  # Habilitar SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Configuración de Firewall (Abrir puertos para SSH y optimizar Tailscale)
  networking.firewall = {
    enable = true;
    checkReversePath = "loose"; # Necesario para que Tailscale funcione bien
    allowedUDPPorts = [ 41641 ]; # Puerto oficial Tailscale
    allowedTCPPorts = [ 22 ];    # Puerto estándar SSH
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
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ]; # Docker añadido por si acaso
  };

  # --- VARIABLES DE ENTORNO ---
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # Ayuda con cursores invisibles en AMD/Wayland
  };
  
  # Nota sobre Sunshine/Moonlight:
  # Como esta es la Laptop, actuará principalmente como CLIENTE (Moonlight).
  # El paquete 'moonlight-qt' debe ir en tu nix/home/default.nix.
}
