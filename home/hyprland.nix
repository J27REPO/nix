{ pkgs, kbLayout, kbOptions, monitorConfig, hostname, ... }: 

{
  wayland.windowManager.hyprland = {
    enable = true;
    
    # Desactivamos Waybar como pediste
    # systemd.user.services.waybar.enable = false; 

    settings = {
      
      # --- MONITORES ---
      monitor = [
        monitorConfig
      ];

      # --- WINDOW RULES ---
      windowrulev2 = [
        "float, class:^(floating_.*)$"  # Flotar cualquier cosa que empiece por floating_
        "center, class:^(floating_.*)$"
        "size 60% 60%, class:^(floating_.*)$"
      ]; 

      exec-once = [
              "vicinae server"
              "swww-daemon"
              "swww img ~/.config/hypr/wallpaper.png"
              "udiskie --tray &"
              "swayosd-server"
            ];
      bindr = [
              "SUPER, SUPER_L, exec, vicinae toggle"
            ];

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # --- VARIABLES ---
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "thunar";
      "$menu" = "rofi -show drun";
      
      # --- INPUT (TECLADO DINÁMICO) ---
      input = {
        kb_layout = kbLayout;    # Se rellena solo (es o us)
        kb_options = kbOptions;  # Se rellena solo (swap alt/win...)
        follow_mouse = 1;
        touchpad.natural_scroll = "no";
        sensitivity = 0;
      };

      # --- ESTÉTICA ---
      general = {
        gaps_in = 2;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgba(00f7ffee) rgba(bd00ffee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      gesture = if hostname == "laptop" then [
        "3, horizontal, workspace"
      ] else [];

      animations = {
        enabled = "yes";
        bezier = "fastBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 2, fastBezier"
          "windowsOut, 1, 2, default, popin 80%"
          "border, 1, 3, default"
          "fade, 1, 2, default"
          "workspaces, 1, 2, default"
        ];
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };
      binde = [
        # Volumen (SwayOSD + Sonido)
        # Usamos canberra-gtk-play para tocar el sonido del sistema
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise && canberra-gtk-play -i audio-volume-change -d 'changeVolume'"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower && canberra-gtk-play -i audio-volume-change -d 'changeVolume'"
        
        # Brillo (Laptop) - Sin sonido, solo visual
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];

      # --- TUS KEYBINDINGS (Estilo JaKooLit) ---
      bind = [
        # Mute (No necesita repetición)
            ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
            ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
        # Apps
        "$mainMod SHIFT, P, exec, grim -g \"$(slurp)\" - | wl-copy"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mainMod, T, exec, $terminal"
        "$mainMod, E, exec, $fileManager"
        
        # Lanzar flotantes usando el truco de la clase
        "$mainMod ALT, T, exec, kitty --class floating_kitty"
        "$mainMod ALT, E, exec, thunar --class floating_thunar"
        
        "$mainMod, W, exec, firefox"
        "$mainMod, C, exec, code"
        "$mainMod, D, exec, $menu"
        
        # Sistema
        "$mainMod, Q, killactive"
       # "$mainMod, M, exit"
        "$mainMod, SPACE, togglefloating"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"

        # TUS SCRIPTS (Prepáralos para cuando subas los archivos)
         "$mainMod, M, exec, ~/.config/hypr/scripts/RofiBeats.sh" # Radio (Super+M)
       #  "exec-once = ~/.config/hypr/scripts/RainbowBorders.sh"   # Bordes

        # Focus (Flechas)
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Mover Ventanas
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        # Workspaces (1-10)
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Mover a Workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Scroll workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      # Ratón
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
      
     
    };
  };
}
