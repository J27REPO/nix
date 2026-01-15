{ pkgs, kbLayout, kbOptions, ... }: 

{
  wayland.windowManager.hyprland = {
    enable = true;
    
    # Desactivamos Waybar como pediste
    # systemd.user.services.waybar.enable = false; 

    settings = {
      # --- VARIABLES ---
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
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
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
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

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      # --- TUS KEYBINDINGS (Estilo JaKooLit) ---
      bind = [
        # Apps
        "$mainMod, Q, exec, $terminal"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, W, exec, firefox"
        "$mainMod, D, exec, $menu"
        
        # Sistema
        "$mainMod, C, killactive"
        "$mainMod, M, exit"
        "$mainMod, F, togglefloating"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"

        # TUS SCRIPTS (Prepáralos para cuando subas los archivos)
         "$mainMod, M, exec, ~/.config/hypr/scripts/RofiBeats.sh" # Radio (Super+M)
         "exec-once = ~/.config/hypr/scripts/RainbowBorders.sh"   # Bordes

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
      
      # Inicio automático
      exec-once = [
        "fastfetch"
        # "nm-applet --indicator" # Útil si no usas waybar para ver el wifi
      ];
    };
  };
}
