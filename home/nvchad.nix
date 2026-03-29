{ config, pkgs, ... }:

{
  # --- NEOVIM CON NVCHAD GESTIÓN MANUAL ---
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim-unwrapped;

    # Paquetes extra para LSP y desarrollo
    extraPackages = with pkgs; [
      nixd
      lua-language-server
      python3Packages.python-lsp-server
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nixfmt
      black
      prettier
      stylua
      shfmt
      ripgrep
      fd
    ];
  };

  # --- NVCHAD CONFIG (gestionado via home-manager) ---
  # Symlink la config de nvchad desde el repo nix
  home.file.".config/nvim" = {
    source = /home/${config.home.username}/nix/nvchad;
    recursive = true;
  };
}
