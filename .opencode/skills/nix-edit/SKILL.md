---
name: nix-edit
description: Edit NixOS/Nix config files following project conventions
metadata:
  audience: developer
  workflow: nixos
---

## Project Structure
```
~/nix/
├── flake.nix              # Main flake definition, mkHost function
├── home/
│   ├── default.nix        # Main home-manager config (imports others)
│   ├── mime-apps.nix      # Desktop entries and MIME associations
│   ├── nvchad.nix         # Neovim config (NvChad)
│   └── hyprland.nix       # Hyprland window manager config
├── hosts/
│   ├── laptop/default.nix # Laptop-specific config
│   └── macmini/default.nix
└── modules/
    └── core.nix           # Shared NixOS modules
```

## Key Conventions

### Desktop Entries (xdg.desktopEntries)
- Use `exec = "kitty -e nvim %F"` NOT `terminal = true` (avoids "unable to find terminal" error)
- For file managers like Thunar that launch apps directly

### Home Manager Config
- `home.stateVersion` = "24.05" (update when bumping)
- GTK theme goes in `gtk.theme.name` and `gtk.theme.package`
- Icons go in `gtk.iconTheme.name` and `gtk.iconTheme.package`

### Package Declarations
- Use `pkgs.packageName` not `package-name` (camelCase)
- Shared packages between laptop/macmini go in `home/packages` in default.nix
- Host-specific packages go in `hosts/*/default.nix`

### MimeApps Associations
- Use `xdg.mimeApps.defaultApplications` for defaults
- If file already exists, add `force = true` to the xdg.configFile option

### Shell Aliases
- Defined in `programs.zsh.shellAliases`
- `update` alias: `sudo nixos-rebuild switch --flake ~/nix#$(hostname)`

## Testing Changes
After editing, always rebuild with: `sudo nixos-rebuild switch --flake ~/nix#laptop`
