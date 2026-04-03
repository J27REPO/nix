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
    exec = "kitty -e nvim %F";
    mimeType = [ "text/plain" "text/x-log" "text/markdown" "application/x-extension-txt" "inode/x-empty" ];
  };

  # Crear desktop entry para MuPDF (visor de PDF)
  xdg.desktopEntries.mupdf = {
    name = "MuPDF";
    genericName = "PDF Viewer";
    comment = "Visor de documentos PDF";
    icon = "mupdf";
    type = "Application";
    categories = [ "Office" "Viewer" ];
    exec = "mupdf %F";
    mimeType = [ "application/pdf" ];
  };

  # Crear desktop entry para Zathura (visor de PDF con vim-like controls)
  xdg.desktopEntries.zathura = {
    name = "Zathura";
    genericName = "PDF Viewer";
    comment = "Visor de documentos PDF con atajos vim";
    icon = "zathura";
    type = "Application";
    categories = [ "Office" "Viewer" ];
    exec = "zathura %F";
    mimeType = [ "application/pdf" ];
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
      # PDF - abrir con zathura por defecto
      "application/pdf" = [ "zathura.desktop" ];
    };
    
    # Asociaciones adicionales (no forzadas, pero sugeridas)
    associations.added = {
      "text/plain" = [ "nvim.desktop" ];
      "text/x-log" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
      "application/pdf" = [ "zathura.desktop" ];
    };
  };
}
