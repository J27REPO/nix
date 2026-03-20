{ pkgs, ... }:

{
  # Crear desktop entry para Neovim (si no existe uno en el sistema)
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    comment = "Edit text files with Neovim";
    icon = "nvim";
    type = "Application";
    categories = [ "TextEditor" "Development" "Utility" ];
    terminal = true;
    exec = "nvim %F";
    mimeType = [ "text/plain" "text/x-log" "text/markdown" "application/x-extension-txt" "inode/x-empty" ];
  };

  # Asociaciones MIME para que Thunar abra archivos de texto con Neovim
  xdg.mimeApps = {
    enable = true;
    
    # Asociaciones predeterminadas
    defaultApplications = {
      "text/plain" = [ "nvim.desktop" ];
      "text/x-log" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
      "application/x-extension-txt" = [ "nvim.desktop" ];
      "inode/x-empty" = [ "nvim.desktop" ];
      # Archivos sin extensión detectados como genéricos
      "application/octet-stream" = [ "nvim.desktop" ];
    };
    
    # Asociaciones adicionales (no forzadas, pero sugeridas)
    associations.added = {
      "text/plain" = [ "nvim.desktop" ];
      "text/x-log" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
    };
  };
}
