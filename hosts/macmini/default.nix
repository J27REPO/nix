{ pkgs, lib, user, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  
  # Disable firewalld - we use networking.firewall instead
  services.firewalld.enable = lib.mkForce false;

  boot.kernelParams = [
    "snd_hda_intel.model=apple-headset-multi"
    "i915.enable_fbc=1"          # Compresión de framebuffer: reduce uso de ancho de banda de memoria
    "transparent_hugepage=madvise" # Huge pages solo cuando la app las solicita (mejor que always)
  ];

  # Desktop+server: schedutil usa datos del scheduler para escalar frecuencia — mejor que ondemand
  powerManagement.cpuFreqGovernor = "schedutil";
  boot.kernelModules = [ "uinput" ];
  boot.initrd.kernelModules = [ "i915" ];           # Early KMS: i915 en initrd para TTY con aceleración
  boot.loader.timeout = 3;                          # Override del 0 de core.nix — tiempo de recuperación
  boot.blacklistedKernelModules = [ "b43" "bcma" ]; # WiFi no usado; evita errores de firmware b43 en cada arranque

  # uinput: permisos para input devices en usuarios
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess", MODE="0660", GROUP="uinput"
  '';

  # 1. Bootloader y Wake on LAN
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  

  # WoL eliminado - no se necesita acceso remoto

  # --- ARRANQUE SIN ESPERAR RED ---
  # No bloquear el arranque esperando a que la red esté online
  systemd.network.wait-online.enable = false;
  # dhcpcd obtiene IP en background, no bloquea el boot
  networking.dhcpcd.extraConfig = ''
    background yes
  '';

  # 2. Drivers Gráficos e Intel Packages
  # modesetting + DRM i915 (reemplaza el viejo xf86-video-intel, más estable en Ivy Bridge)
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver  # VA-API para Intel Ivy Bridge HD 4000 (i965)
      libvdpau-va-gl      # Fallback VDPAU → VAAPI para apps que lo necesiten
    ];
  };
  # Forzar driver i965 para HD 4000; sin esto libva puede seleccionar el incorrecto
  environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";
  environment.sessionVariables.VDPAU_DRIVER = "va_gl"; # VDPAU → VA-API (par de LIBVA_DRIVER_NAME)
  environment.sessionVariables.ZED_ALLOW_EMULATED_GPU = "1"; # Permitir GPU emulada para Zed (llvmpipe)

  # Microcode Intel: aplica mitigaciones Spectre/Meltdown a nivel hardware (más rápido que SW)
  hardware.cpu.intel.updateMicrocode = true;

  # Daemon térmico Intel: gestiona P-states antes de que el kernel haga throttling de golpe
  # Útil para cargas sostenidas (builds nix)
  services.thermald.enable = true;

  # TRIM periódico para SSD (prolonga vida útil y mantiene rendimiento de escritura)
  services.fstrim.enable = true;
  environment.systemPackages = [ pkgs.ethtool ];
security.polkit.extraConfig = ''
  polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.login1.suspend" &&
        subject.isInGroup("wheel")) {
      return polkit.Result.YES;
    }
  });
'';
  # --- ACCESO REMOTO ---

  # 3. SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # 4. DNS (Tailscale desactivado - no se necesita acceso remoto)
  # networking.hostName ya definido en flake.nix — eliminado duplicado
  services.resolved = {
    enable = true;
    settings.Resolve.MulticastDNS = "no"; # Evita conflicto con Avahi (mDNS dual-stack warning)
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Docker daemon
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    daemon.settings = {
      storage-driver = "overlay2";
      log-driver = "json-file";
      log-opts.max-size = "10m";
      log-opts.max-file = "3";
    };
  };
  systemd.services.docker.wantedBy = [ "multi-user.target" ];
  systemd.services.docker.after = [ "basic.target" ];
  systemd.services.docker.requires = lib.mkForce [ ];

  # 6. Firewall manual (Refuerzo para SSH)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # --- USUARIO Y GRUPOS ---
  
  # Creamos el grupo uinput para la regla udev
  users.groups.uinput = {};

  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "docker" "uinput" "input" ]; # networkmanager eliminado (no hay NM en este host)
  };
}
