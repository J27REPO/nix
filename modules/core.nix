{ pkgs, lib, user, ... }:

{
  # 1. Habilitar Flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true; # Deduplica ficheros idénticos en el store con hardlinks
    max-jobs = "auto";          # Builds/descargas en paralelo (usa todos los cores)
    trusted-users = [ "root" user ]; # Permite a j27 usar substituters directamente
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/SkPMuW6dN7vvU="
    ];
  };
  # Builds de nix en prioridad idle — no compiten con el uso normal del PC
  nix.daemonCPUSchedPolicy = "idle";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
  programs.ssh.startAgent = true;
  programs.zsh.enable = true;
  # programs.adb eliminado: systemd 258 gestiona udev/uaccess automáticamente
  # android-tools ya está en home packages — funciona sin módulo adicional

  # Firmware redistribuible: WiFi (BCM4331), Bluetooth, iGPU, etc.
  hardware.graphics.enable32Bit = true;
  hardware.enableRedistributableFirmware = true;
  services.usbmuxd.enable = true;
  services.flatpak.enable = true;
  services.blueman.enable = true;
  services.firewalld.enable = false;
  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk 
    ];
    config.common.default = [ "hyprland" "gtk" ]; 
  };
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.gsettings-desktop-schemas pkgs.gtk3 ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", MODE="0666"
  '';
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
  
    libusb1
    libimobiledevice
    usbmuxd
    glibc
    readline
    
   # Librerías para AppImages y Apps Gráficas (Soluciona Helium)
   alsa-lib
   libxkbcommon
   libGL
   wayland
   vulkan-loader
        dbus
        glib
        nss
        nspr
        atk
        at-spi2-atk
        cups
        libdrm
        mesa        # Proporciona drivers y suele incluir gbm
        libgbm      # Se añade directamente, no como xorg.libgbm
        gtk3
        pango
        cairo
        expat
        
        libx11
        libxcursor
        libxrandr
        libxi
        libxinerama
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrender
        libxtst
        libxcb

   # --- LIBRERÍAS 32-BIT PARA WINE/LUTRYS ---
   pkgs.pkgsi686Linux.vulkan-loader
   pkgs.pkgsi686Linux.libglvnd
   pkgs.pkgsi686Linux.alsa-lib
   pkgs.pkgsi686Linux.libX11
   pkgs.pkgsi686Linux.libXcursor
   pkgs.pkgsi686Linux.libXrandr
   pkgs.pkgsi686Linux.libXi
   pkgs.pkgsi686Linux.libXinerama
   pkgs.pkgsi686Linux.libXcomposite
   pkgs.pkgsi686Linux.libXdamage
   pkgs.pkgsi686Linux.libXext
   pkgs.pkgsi686Linux.libXfixes
   pkgs.pkgsi686Linux.libXrender
   pkgs.pkgsi686Linux.libXtst
   pkgs.pkgsi686Linux.libxcb
   pkgs.pkgsi686Linux.libxml2
   pkgs.pkgsi686Linux.libxslt
   pkgs.pkgsi686Linux.libpcap
   pkgs.pkgsi686Linux.dbus
   pkgs.pkgsi686Linux.gtk3
   pkgs.pkgsi686Linux.pango
   pkgs.pkgsi686Linux.cairo
   pkgs.pkgsi686Linux.expat
   pkgs.pkgsi686Linux.gettext
   pkgs.pkgsi686Linux.zlib
   pkgs.pkgsi686Linux.ncurses5
   pkgs.pkgsi686Linux.libsodium
  ];
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  # Añade tu usuario al grupo docker para no usar sudo siempre
  users.users.${user}.extraGroups = [ "docker" "wheel" "dialout" ];

  # Solución:告诉 Docker gestionar sus propias reglas de firewall
  systemd.services.docker.serviceConfig.ExecStartPost = lib.mkAfter ''
    ${pkgs.iptables}/bin/iptables -F
    ${pkgs.iptables}/bin/iptables -X
  ''; # networkmanager/adbusers eliminados (systemd 258 gestiona acceso USB automáticamente)
  # 2. Paquetes del Sistema Comunes
  environment.systemPackages = with pkgs; [
    git vim wget curl kitty fastfetch
    gnumake gcc binutils
    appimage-run
    # Gaming: Lutris + Wine
    lutris
    gamemode  # Ya instalado en laptop, necesario para lutris
    aichat # Cliente de terminal para LLMs como Ollama (como alternativa a "clawd bot")
    gsettings-desktop-schemas
      gtk3
      xdg-desktop-portal-gtk  # Asegúrate de que esté aquí también
          glib                    # Para el comando gsettings
          dconf
          hicolor-icon-theme
            adwaita-icon-theme
    # EL SCRIPT MAGICO 'RELOAD'
    (writeShellScriptBin "reload" ''
      echo "🔄 Reconstruyendo NixOS para: $(hostname)..."
      flakePath="$HOME/nix"
      git -C $flakePath add .
      sudo nixos-rebuild switch --flake "$flakePath#$(hostname)" --impure
      echo "✅ ¡Listo! Sistema actualizado."
      fastfetch # Muestra tu Mew al terminar
    '')
  ];

  # Fastfetch: config gestionada en home/default.nix → ~/.config/fastfetch/config.jsonc
  # (XDG_CONFIG_HOME tiene prioridad sobre /etc — eliminar aquí evita redundancia)
  programs.hyprland.enable = true;
  
  # Activar hyprland wayland
  programs.hyprland.xwayland.enable = true;
  # Servicios de bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # Habilitar sonido con Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.gvfs.enable = true;    # Necesario para Thunar y montajes
    services.udisks2.enable = true; # Gestiona los discos duros y USBs
  # Bloqueo de pantalla 
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Auto inicio de sesion 
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = user;

  # No passwd con sudo 
  security.sudo.wheelNeedsPassword = false;

  # Servicios de gestión de energía para pantalla
  services.logind = {
    # Configuración para manejar la energía y el apagado de pantalla
    # powerKey eliminado: duplicado de settings.Login.HandlePowerKey (abajo)
    settings = {
      Login = {
        HandleLidSwitch = "suspend";               # era lidSwitch (renombrado en 26.05)
        HandleLidSwitchExternalPower = "ignore";   # era lidSwitchExternalPower
        HandlePowerKey = "hibernate";
        HandleSuspendKey = "suspend";
        HandleHibernateKey = "hibernate";
        IdleActionSec = 900;
        IdleAction = "lock";
      };
    };
  };

  # Habilitar screen saver y power management
  hardware.acpilight.enable = true;

  boot.tmp.cleanOnBoot = true; # Limpia /tmp en cada arranque
  boot.loader.systemd-boot.configurationLimit = 5;

  # --- TUNING DE MEMORIA/IO (SSD + 16 GB RAM) ---
  boot.kernel.sysctl = {
    "vm.swappiness"               = 10;   # Evita swap salvo emergencia (default 60)
    "vm.dirty_ratio"              = 40;   # Máx % RAM para dirty pages antes de bloquear escrituras
    "vm.dirty_background_ratio"   = 10;   # % RAM para iniciar writeback en background
    "vm.dirty_expire_centisecs"   = 3000; # 30s antes de forzar escritura de datos sucios
    "vm.dirty_writeback_centisecs"= 300;  # Intervalo entre pasadas de writeback (3s)
    "vm.vfs_cache_pressure"       = 50;   # Retiene más caché de directorios/inodos en RAM
  };

  # --- TIMEOUTS SYSTEMD (default 90s → 15s) ---
  # Si un servicio falla en arranque, falla rápido en lugar de congelar 90s
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "15s";
    DefaultTimeoutStopSec = "15s";
  };

  # --- JOURNAL: limitar tamaño máximo ---
  services.journald.extraConfig = ''
    Storage=auto
    Compress=yes
    SystemMaxUse=500M
    SystemMaxFileSize=100M
    RuntimeMaxUse=100M
  '';
  boot.loader.timeout = lib.mkDefault 0; # Hosts individuales pueden override (ej: macmini usa 3)
  nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

}
