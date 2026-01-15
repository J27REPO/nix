{ pkgs, user, ... }:

{
  imports = [ ./hyprland.nix ];

  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.05";

  # --- VARIABLES DE ENTORNO (Micro por defecto) ---
  home.sessionVariables = {
    EDITOR = "micro";
    VISUAL = "micro";
  };

  home.packages = with pkgs; [
    # Navegadores y Apps
    firefox
    discord
    spotify
    dolphin
    
    # Herramientas de Sistema
    rofi-wayland
    waybar
    pavucontrol
    micro      # <--- TU NUEVO EDITOR FAVORITO
    
    # Multimedia y Scripts
    mpv
    mpvpaper
    grim
    slurp
    wl-clipboard
    
    # Fuentes
    nerd-fonts.jetbrains-mono
  ];

  # --- CONFIGURACIÓN DE KITTY (Con efecto de cursor) ---
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;
      confirm_os_window_close = 0; # Cierra sin preguntar
      
      # EFECTOS DEL CURSOR
      cursor_shape = "beam";     # Forma: bloque, viga (beam) o subrayado
      cursor_beam_thickness = 1.5;
      cursor_trail = 3;          # <--- LA MAGIA: Longitud del rastro (1 min - 100 max)
      cursor_trail_decay = "0.1 0.4"; # Cómo se desvanece
    };
  };

  # --- TEMA GTK (Para que Micro/Dolphin se vean oscuros) ---
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # --- ZSH Y STARSHIP ---
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake ~/nixos-config#laptop"; # Ajusta el hostname según toque
      
      # Alias modernos
      ls = "eza --icons";
      cat = "bat";
      grep = "grep --color=auto";
      
      # Alias para editar rápido con micro
      conf = "micro ~/nixos-config/flake.nix";
      vi = "micro";   # Por si la costumbre te hace escribir vi
      vim = "micro";
      nano = "micro";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };

  programs.eza = { enable = true; git = true; icons = "auto"; };
  programs.bat = { enable = true; config.theme = "TwoDark"; };
  programs.zoxide = { enable = true; enableZshIntegration = true; };
  programs.fzf = { enable = true; enableZshIntegration = true; };

  # --- GESTIÓN DE ARCHIVOS ---
  xdg.configFile."fastfetch/mew.png".source = ./mew.png;
  
  # Tu config de Fastfetch
  xdg.configFile."fastfetch/config.jsonc".text = ''
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

  xdg.configFile."rofi/config.rasi".source = ./rofi/theme.rasi;
  
  xdg.configFile."hypr/scripts/RainbowBorders.sh" = {
    source = ./scripts/RainbowBorders.sh;
    executable = true;
  };

  xdg.configFile."hypr/scripts/RofiBeats.sh" = {
    source = ./scripts/RofiBeats.sh;
    executable = true;
  };

  xdg.configFile."rofi/online_music.list".source = ./scripts/online_music.list;

  programs.git = {
    enable = true;
    userName = "J27REPO";
    userEmail = "josesf2004@gmail.com";
  };
}
