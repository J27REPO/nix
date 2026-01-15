{ pkgs, ... }:

{
  # Paquetes básicos para ambos
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    
    # EL SCRIPT DE RELOAD
    (writeShellScriptBin "reload" ''
      echo "🔄 Reconstruyendo configuración para: $(hostname)..."
      # Asume que tu config está en ~/nixos-config. Ajusta la ruta si es necesario.
      flakePath="$HOME/nixos-config"
      
      # Git add es necesario si usas flakes con git, si no, nix no ve los archivos nuevos
      git -C $flakePath add .
      
      sudo nixos-rebuild switch --flake "$flakePath#$(hostname)"
      
      echo "✅ ¡Sistema actualizado!"
    '')
  ];

  # Habilitar flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
