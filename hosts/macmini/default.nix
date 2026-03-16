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
  # El adaptador USB-Ethernet solo sirve para WoL, no siempre está conectado.
  # Sin esto, systemd espera que aparezca en cada arranque hasta el timeout (~90s).
  systemd.network.wait-online.ignoredInterfaces = [ "enx10ddb1c93253" ];
  # 2. Drivers Gráficos e Intel Packages
  services.xserver.videoDrivers = [ "intel" ]; 
  hardware.graphics.enable = true;
  environment.systemPackages = [ 
    pkgs.ethtool 
    pkgs.intel-vaapi-driver # Driver para que Sunshine codifique video por hardware
  ];
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
  networking.hostName = "macmini";
  services.resolved.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
    # Optimización para hardware antiguo (Intel 3rd Gen) usando CPU
    package = pkgs.ollama; 
  };
  systemd.services.ollama.serviceConfig.Environment = [
    "OLLAMA_NUM_THREADS=4"
    "OLLAMA_KEEP_ALIVE=20m"
  ];

  # Descargar modelo Qwen automáticamente
  systemd.services.ollama-model = {
    description = "Pull Ollama qwen2.5-coder:7b model";
    wantedBy = [ "multi-user.target" ];
    after = [ "ollama.service" ];
    path = [ pkgs.ollama pkgs.curl ];
    script = ''
      # Esperar a que la API de Ollama responda
      until curl -s http://127.0.0.1:11434/api/tags > /dev/null; do
        sleep 5
      done
      # Solo descargar si no está ya instalado
      if ! ollama list | grep -q "qwen2.5-coder:7b"; then
        ollama pull qwen2.5-coder:7b
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # 5. Letta Server (Container)
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.letta = {
    image = "letta/letta:latest";
    # Usamos network=host para conectar fácilmente con Ollama en localhost
    extraOptions = [ "--network=host" ]; 
    volumes = [ "/home/j27/.letta:/root/.letta" ];
    environment = {
      LETTA_OLLAMA_ENDPOINT = "http://localhost:11434";
    };
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
    allowedTCPPorts = [ 22 47984 47989 47990 48010 11434 8283 ];
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
