{ pkgs,user, ... }:

{
  # 1. Habilitar Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
  programs.ssh.startAgent = true;
  programs.zsh.enable = true;
  services.usbmuxd.enable = true;
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
  ];
  virtualisation.docker.enable = true;
  # Añade tu usuario al grupo docker para no usar sudo siempre
  users.users.j27.extraGroups = [ "docker" ];
  # 2. Paquetes del Sistema Comunes
  environment.systemPackages = with pkgs; [
    git vim wget curl kitty fastfetch
    
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

  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 0;
  nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
}
