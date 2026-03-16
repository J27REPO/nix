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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

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
  
  # --- AUTO-CPUFREQ (Gestión automática de frecuencia CPU) ---
  # Reduce la frecuencia del CPU en batería y la sube al cargar.
  # Mejora notablemente la duración de batería sin hacer nada más.
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";  # Ahorra batería cuando no está enchufado
        turbo = "auto";          # Turbo solo cuando hace falta
      };
      charger = {
        governor = "performance"; # Rendimiento máximo enchufado
        turbo = "auto";
      };
    };
  };

  # --- GESTIÓN DE ENERGÍA: evitar que el portátil "resucite" tras poweroff ---
  # Los controladores USB (XHC0, XHC1) y el dispositivo PCIe (GP17) tienen
  # habilitada la capacidad de despertar el sistema desde S5 (apagado).
  # Esto hace que un ratón, cable USB o cualquier periferico reactive el equipo
  # a estado S3 (suspendido), dejando el LED encendido y drenando la batería.
  # Este servicio los desactiva al arrancar de forma idempotente.
  systemd.services.disable-acpi-wakeup = {
    description = "Deshabilitar wakeup sources USB/PCIe para evitar resurrección tras poweroff";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "disable-acpi-wakeup" ''
        for dev in XHC0 XHC1 GP17; do
          if grep -qP "^$dev\s+.*\*enabled" /proc/acpi/wakeup; then
            echo "$dev" > /proc/acpi/wakeup
            echo "Wakeup deshabilitado: $dev"
          fi
        done
      '';
    };
  };

  # --- OPTIMIZACIONES DE RENDIMIENTO Y BATERÍA ---

  # 1. ZRAM: swap en RAM comprimida — más rápido que SSD y sin desgastarlo
  #    Con 7GB RAM, 4GB de zram comprimido equivale a ~8-12GB reales
  zramSwap = {
    enable = true;
    algorithm = "zstd";   # Mejor ratio compresión/velocidad
    memoryPercent = 50;   # Usa hasta el 50% de RAM para zram (~3.5GB)
  };

  # 2. SWAPPINESS: preferir RAM sobre swap (0=nunca, 100=siempre, default=60)
  #    Con 7GB RAM no hay razón para usar swap salvo emergencia
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 15;           # % RAM para escrituras en caché
    "vm.dirty_background_ratio" = 5; # Empieza a vaciar caché en segundo plano
  };

  # 3. KERNEL PARAMS: optimizaciones AMD + NVMe
  boot.kernelParams = [
    # NVMe: permite estados de bajo consumo (ahorra ~0.5-1W en reposo)
    "nvme_core.default_ps_max_latency_us=5500"
    # AMD pstate activo (ya cargado como driver, esto lo confirma)
    "amd_pstate=active"
  ];

  # El paquete 'moonlight-qt' debe ir en tu nix/home/default.nix.
}
