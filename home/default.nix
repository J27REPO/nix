{config,  pkgs, user, inputs, hostname, ... }:

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
    moonlight-qt
    discord
    unrar
    winetricks
    wineWowPackages.stable
    zotero
    antigravity
    morgen
   libimobiledevice
      libusbmuxd
      usbmuxd
      usbutils
      pkg-config
    ifuse
    mupdf
    unzip
    blueman
    udiskie
    firefox
    inputs.autofirma-nix.packages.${pkgs.system}.autofirma
    thunar  
    libreoffice
    vicinae   
    obsidian
    swww
    psmisc
    feh
    gemini-cli
    swayosd
    hyprshade
    gammastep
    hypridle
    pywal
    # Herramientas de Sistema
    jdk21
    htop
    python3
    rofi
    waybar
    pavucontrol
    micro     
    
    # Multimedia y Scripts
    mpv
    mpvpaper
    grim
    slurp
    wl-clipboard
    # SONIDO Y FEEDBACK
      sound-theme-freedesktop   # Los sonidos estándar (pop, click, etc.)
      libcanberra-gtk3          # Contiene el comando 'canberra-gtk-play'
    # Anime Streaming
    ani-cli
    # Fuentes
    nerd-fonts.jetbrains-mono
  ];

  # 2. Copiar tu imagen a una ruta conocida en el sistema (~/.config/hypr/wallpaper.png)
    xdg.configFile."hypr/wallpaper.png".source = if hostname == "laptop" then ./laptop_wallpaper.jpg else ./wallpaper.png;
  
  # --- CONFIGURACIÓN DE KITTY (Tema Neon Moderno) ---
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;
      confirm_os_window_close = 0; # Cierra sin preguntar
      
      # EFECTOS DEL CURSOR
      cursor_shape = "block";
      shell_integration = "no-cursor"; # Evita que la shell cambie el cursor
      cursor_trail = 3;          
      cursor_trail_decay = "0.1 0.4"; 

      # ESTÉTICA MODERNA
      window_padding_width = 15;   # Margen interno para que el texto no toque el borde
      background_opacity = "0.90"; # Un poco de transparencia
      url_style = "curly";         # Subrayado ondulado para links
      disable_ligatures = "never"; # Asegura que las ligaduras (->, !=) se vean bonitas

      # BARRA DE PESTAÑAS (TABS)
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      # TEMA CYBERPUNK SUAVE
      foreground = "#d0d0d0";
      background = "#151515";
      cursor = "#cc66cc";
      
      # Paleta Cyberpunk suave
      color0 = "#151515";   # Negro más oscuro
      color1 = "#cc5555";   # Rojo suave
      color2 = "#77cc88";   # Verde suave
      color3 = "#cc9944";   # Naranja suave
      color4 = "#5599cc";   # Azul suave
      color5 = "#aa66cc";   # Púrpura suave
      color6 = "#55cccc";   # Cian suave
      color7 = "#d0d0d0";   # Blanco suave
      
      # Colores brillantes (menos intensos)
      color8 = "#555555";   # Gris más oscuro
      color9 = "#dd7799";   # Rosa suave
      color10 = "#88dd99";  # Verde suave
      color11 = "#ddaa55";  # Amarillo suave
      color12 = "#77aadd";  # Azul suave
      color13 = "#bb88dd";  # Púrpura suave
      color14 = "#88dddd";  # Cian suave
      color15 = "#e0e0e0";  # Blanco suave
      
      # Selección y búsqueda (tonos suaves)
      selection_foreground = "#151515";
      selection_background = "#5599cc";
      search_color_matches = "#cc5555";
      search_color_background = "#d0d0d0";
    };
    keybindings = {
          "ctrl+c" = "copy_to_clipboard";
          "ctrl+v" = "paste_from_clipboard";
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
    
    # Corregido: initContent -> initExtra (estándar de home-manager)
    initContent = ''
      export PATH="$HOME/.opencode/bin:$PATH"
      fastfetch
      stty intr ^Z
      
      # Forzar cursor de bloque en cada nuevo prompt
      # \e[2 q = Block, \e[6 q = Beam
      precmd() {
        echo -ne '\e[2 q'
      }
    '';

    shellAliases = {
      opencode = "opencode";
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
      
      # Alias para apagar pantalla
      apagar = "hyprctl dispatch dpms off";
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
            { "type": "memory", "key": "󰾆 Memory", "keyColor": "green" },
            { "type": "disk", "key": "󰋊 Disk", "keyColor": "green" },
            "break",
            { "type": "colors", "symbol": "block", "block": { "range": [0, 15] } }
        ]
    }
  '';

  xdg.configFile."rofi/theme.rasi".source = ./rofi/theme.rasi;
  
  xdg.configFile."hypr/scripts/RainbowBorders.sh" = {
    source = ./scripts/RainbowBorders.sh;
    executable = true;
  };

  xdg.configFile."hypr/scripts/RofiBeats.sh" = {
    source = ./scripts/RofiBeats.sh;
    executable = true;
  };

  xdg.configFile."hypr/scripts/anime-launcher.sh" = {
    source = ./scripts/anime-launcher.sh;
    executable = true;
  };

   xdg.configFile."rofi/online_music.list".source = ./scripts/online_music.list;
   
   xdg.configFile."hypr/hypridle.conf" = {
     source = ./scripts/hypridle.conf;
   };
   
   xdg.configFile."hypr/scripts/wallpaper-theme.sh" = {
     source = ./scripts/wallpaper-theme.sh;
     executable = true;
   };

  programs.git = {
    enable = true;
    settings.user.name = "J27REPO";
    settings.user.email = "josesf2004@gmail.com";
  };

 home.pointerCursor = {
     gtk.enable = true;
     x11.enable = true;
     name = "Notwaita-Black";
     size = 24;
 
     # USANDO ARCHIVOS LOCALES
     package = pkgs.runCommand "notwaita-cursor" {} ''
       mkdir -p $out/share/icons/Notwaita-Black
       # Copiamos todo el contenido de tu carpeta local al sistema
       cp -r ${./icons/Notwaita-Black}/* $out/share/icons/Notwaita-Black/
     '';
   };

   # --- CONTROL DE LUZ NOCTURNA (Gammastep) ---
   services.gammastep = {
     enable = true;
     provider = "manual"; # Manual para que pongas tu lat/long o lo controles tú
     latitude = 40.4;    # Madrid aprox (puedes cambiarlo)
     longitude = -3.7;
     temperature = {
       day = 6500;   # Color neutro de día
       night = 4500; # Un poco más cálido de noche (no naranja exagerado)
     };
     settings = {
       general.fade = "1"; # Transición suave
     };
   };
  
}
