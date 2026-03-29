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

    # Plugins extra (Copilot) - formato lazy.nvim
    extraPlugins = ''
      return {
        { "zbirenbaum/copilot.lua", event = "InsertEnter" };
        { "zbirenbaum/copilot-cmp", after = "copilot.lua" };
      }
    '';

    # Copiar configuración automáticamente
    hm-activation = true;
    backup = false;
  };

  # --- KEYBINDINGS + COPILOT via extraConfig ---
  # Se carga después de NvChad
  programs.nvchad.extraConfig = ''
    -- Copilot setup
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          next = "<C-]>",
          dismiss = "<C-e>",
        },
      },
      panel = { enabled = false },
    })

    -- Copilot cmp source
    require("copilot_cmp").setup()

    local map = vim.keymap.set

    -- Save file: Space + s + s
    map("n", "<leader>ss", ":w<CR>", { desc = "Save file" })

    -- Close neovim with save: Space + q + q
    map("n", "<leader>qq", ":w<CR>:q<CR>", { desc = "Save and close neovim" })
  '';
}
