{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Configuración compartida
  # Nota: Usamos 'extraConfig' para inyectar texto puro de config
  programs.hyprland.extraConfig = ''
    # --- VARIABLES COMUNES ---
    $mod = SUPER
    $terminal = alacritty

    # --- ESTILO ---
    general {
        gaps_in = 5
        gaps_out = 10
        border_size = 2
        col.active_border = rgba(33ccffee)
        layout = dwindle
    }

    # --- KEYBINDS COMUNES ---
    bind = $mod, Q, exec, $terminal
    bind = $mod, C, killactive
    bind = $mod, M, exit
    bind = $mod, E, exec, dolphin
  '';
}
