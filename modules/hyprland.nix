{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  # Configuración base (sin monitores)
  programs.hyprland.extraConfig = ''
    $mod = SUPER
    
    # Ajustes visuales generales
    general {
        gaps_in = 5
        gaps_out = 10
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        layout = dwindle
    }
    
    bind = $mod, Q, exec, kitty
    bind = $mod, M, exit
    bind = $mod, E, exec, dolphin
    bind = $mod, SPACE, exec, wofi --show drun
  '';
}
