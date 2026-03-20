{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];

  programs.nvchad = {
    enable = true;
    
    # LSPs y herramientas para desarrollo
    extraPackages = with pkgs; [
      # LSP servers
      nixd              # Nix
      lua-language-server
      python3Packages.python-lsp-server
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON, ESLint
      
      # Formateadores y linters
      nixfmt
      black
      prettier
      stylua
      shfmt
      
      # Debugging
      delve   # Go debugger (por si acaso)
      
      # Herramientas útiles
      ripgrep
      fd
    ];

    # Copiar configuración automáticamente
    hm-activation = true;
    backup = false;  # Desactivamos backup para no llenar ~/.config
  };
}
