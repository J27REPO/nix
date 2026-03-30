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
      marksman  # Markdown LSP
      
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

    # Plugins extra - formato lazy.nvim
    extraPlugins = ''
      return {
        { "zbirenbaum/copilot.lua", event = "InsertEnter" };
        { "zbirenbaum/copilot-cmp", after = "copilot.lua" };

        -- TODO comments highlighting
        { "folke/todo-comments.nvim", dependencies = "nvim-lua/plenary.nvim" };

        -- Markdown rendering estilo Obsidian
        { "MeanderingProgrammer/render-markdown.nvim", after = "nvim-treesitter" };

        -- Snacks: dashboard, indent guides, status column, etc.
        { "folke/snacks.nvim" };

        -- Colorizer: muestra colores hex en el texto
        { "NvChad/nvim-colorizer.lua" };

        -- Telescope UI select mejora
        { "nvim-telescope/telescope-ui-select.nvim" };

        -- Trouble: panel de diagnostics
        { "folke/trouble.nvim", dependencies = "nvim-treesitter" };
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

    -- TODO comments
    require("todo-comments").setup()

    -- Markdown rendering (Obsidian style)
    require("render-markdown").setup({})

    -- Snacks: dashboard, indent guides, etc.
    require("snacks").setup()

    -- Colorizer: muestra colores hex en tiempo real
    require("colorizer").setup()

    -- Telescope UI select
    require("telescope").load_extension("ui-select")

    -- Trouble: diagnostics panel
    require("trouble").setup()

    local map = vim.keymap.set

    -- Save file: Space + s + s
    map("n", "<leader>ss", ":w<CR>", { desc = "Save file" })

    -- Close neovim with save: Space + q + q
    map("n", "<leader>qq", ":w<CR>:q<CR>", { desc = "Save and close neovim" })

    -- Ctrl+C / Ctrl+V para copiar y pegar (usa clipboard del sistema)
    map("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
    map("n", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
    map("v", "<C-v>", '"+p', { desc = "Paste from system clipboard" })
    map("n", "<C-v>", '"+p', { desc = "Paste from system clipboard" })
    map("i", "<C-v>", '<C-r>+', { desc = "Paste from system clipboard in insert mode" })

    -- Ctrl+A para seleccionar todo el texto
    map("n", "<C-a>", "ggVG", { desc = "Select all text" })
    map("i", "<C-a>", "<Esc>ggVG", { desc = "Select all text" })
  '';
}
