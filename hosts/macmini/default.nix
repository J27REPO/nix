{ pkgs, user, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  
  boot.kernelParams = [ "snd_hda_intel.model=apple-headset-multi" ];
  boot.kernelModules = [ "uinput" ];

  # Regla uinput corregida para que Sunshine tenga permisos totales de entrada
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess", MODE="0660", GROUP="uinput"
  '';

  # 1. Bootloader y Wake on LAN
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  

networking.interfaces.enx10ddb1c93253.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };
  # 2. Drivers Gráficos e Intel Packages
  services.xserver.videoDrivers = [ "intel" ]; 
  hardware.graphics.enable = true;
  environment.systemPackages = [ 
    pkgs.ethtool 
    pkgs.intel-vaapi-driver # Driver para que Sunshine codifique video por hardware
  ];

  # --- ACCESO REMOTO ---

  # 3. SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # 4. Tailscale y DNS
  services.tailscale.enable = true;
  networking.hostName = "macmini";
  services.resolved.enable = true;

  # 5. Sunshine (Streaming)
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # 6. Firewall manual (Refuerzo para Sunshine y SSH)
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedTCPPorts = [ 22 47984 47989 47990 48010 ];
    allowedUDPPorts = [ 41641 47998 47999 48000 48002 48010 ];
  };

  # --- USUARIO Y GRUPOS ---
  
  # Creamos el grupo uinput para la regla udev
  users.groups.uinput = {};

  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "uinput" "input" ];
  };
}
