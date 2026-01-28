{ pkgs,user, ... }:

{
  # 1. Habilitar Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
  programs.ssh.startAgent = true;
  programs.zsh.enable = true;
  services.usbmuxd.enable = true;
  services.flatpak.enable = true;
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
        libxcb
        dbus        # <--- Esto soluciona tu error actual
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
        
xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXinerama
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
  ];
  virtualisation.docker.enable = true;
  # Añade tu usuario al grupo docker para no usar sudo siempre
  users.users.j27.extraGroups = [ "docker" "wheel" "networkmanager" "dialout" ];
  # 2. Paquetes del Sistema Comunes
  environment.systemPackages = with pkgs; [
    git vim wget curl kitty fastfetch
    appimage-run
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

  # 3. Tu Configuración de Fastfetch (Integrada desde tu archivo)
  environment.etc."fastfetch/config.jsonc".text = ''
    {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
            "source": "~/.config/fastfetch/mew.png",
            "type": "kitty-direct",
            "height": 16,
            "width": 30,
            "padding": { "top": 2, "left": 1 }
        },
        "modules": [
            "break",
            { "type": "custom", "format": "\u001b[0;WWELCOME BACK! \u001b[0;35mJ27\u001b[1;37m@\u001b[0;36mNixOS" },
            { "type": "custom", "format": "\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m━\u001b[35m═\u001b[36m" },
            { "type": "os", "key": " Distro", "keyColor": "yellow" },
            { "type": "kernel", "key": " Kernel", "keyColor": "yellow" },
            { "type": "packages", "key": "󰏖 Packages", "keyColor": "yellow" },
            { "type": "shell", "key": " Shell", "keyColor": "yellow" },
            "break",
            { "type": "wm", "key": " WM", "keyColor": "blue" },
            { "type": "terminal", "key": " Terminal", "keyColor": "blue" },
            "break",
            { "type": "cpu", "key": "󰻠 CPU", "keyColor": "green" },
            { "type": "gpu", "key": "󰻑 GPU", "keyColor": "green" },
            { "type": "memory", "key": "󰾆 Memory", "keyColor": "green" },
            { "type": "disk", "key": "󰋊 Disk", "keyColor": "green" },
            "break",
            { "type": "colors", "symbol": "block", "block": { "range": [0, 15] } }
        ]
    }
  '';
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
    lidSwitch = "suspend";
    lidSwitchExternalPower = "ignore";
    powerKey = "hibernate";
    
    # Configuración moderna usando settings
    settings = {
      Login = {
        HandlePowerKey = "hibernate";
        HandleSuspendKey = "suspend";
        HandleHibernateKey = "hibernate";
        IdleActionSec = 900;
        IdleAction = "lock";
      };
    };
  };

  # Habilitar screen saver y power management
  programs.light.enable = true;

  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 0;
  nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

}
