{ pkgs, user, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  
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
  # El adaptador USB-Ethernet solo sirve para WoL, no siempre está conectado.
  # Sin esto, systemd espera que aparezca en cada arranque hasta el timeout (~90s).
  systemd.network.wait-online.ignoredInterfaces = [ "enx10ddb1c93253" ];
  # Impide que dhcpcd espere este adaptador USB-Ethernet y cause 90s de timeout en arranque
  networking.dhcpcd.denyInterfaces = [ "enx10ddb1c93253" ];

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

  # Microcode Intel: aplica mitigaciones Spectre/Meltdown a nivel hardware (más rápido que SW)
  hardware.cpu.intel.updateMicrocode = true;

  # Daemon térmico Intel: gestiona P-states antes de que el kernel haga throttling de golpe
  # Útil para cargas sostenidas (Sunshine streaming, builds nix)
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

  # 4. Tailscale y DNS
  services.tailscale.enable = true;
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

  # 5. Letta Server (Container)
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.letta = {
    image = "letta/letta:latest";
    # Usamos network=host para conectar fácilmente con Ollama en localhost
    extraOptions = [ "--network=host" ]; 
    volumes = [ "/home/j27/.letta:/root/.letta" ];
  };

  # 6. Sunshine (Streaming)
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
    allowedTCPPorts = [ 22 47984 47989 47990 48010 8283 ]; # SSH, Sunshine, Letta
    allowedUDPPorts = [ 41641 47998 47999 48000 48002 48010 ];
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
