# NixOS Dotfiles

My NixOS configuration with Hyprland, optimized for laptop and macmini.

## Structure

```
nix/
├── flake.nix              # Main flake (inputs, outputs, mkHost)
├── flake.lock             # Locked versions
├── version.txt            # Current version (v1.4.0)
├── CHANGELOG.md           # Version history
├── home/                  # Home-manager user config
│   ├── default.nix        # Main HM config
│   ├── hyprland.nix       # Hyprland window manager
│   ├── nvchad.nix         # Neovim NvChad config
│   └── mime-apps.nix      # Desktop entries & MIME
├── hosts/
│   ├── laptop/default.nix # Laptop-specific config
│   └── macmini/default.nix # Mac Mini-specific config
└── modules/
    └── core.nix           # Shared modules (boot, networking, etc.)
```

## Features

- **Hyprland** - Wayland compositor with gamepoint, screenshot, and gesture support
- **Home Manager** - User configuration in Nix
- **Flakes** - Reproducible builds with locked inputs
- **Multi-host** - Shared config between laptop and macmini

## Quick Start

### Use as Inspiration

1. Fork or copy the parts you need
2. Update `flake.nix` with your inputs
3. Edit `hosts/<your-host>/default.nix` for your hardware
4. Run `sudo nixos-rebuild switch --flake .#your-host`

### First Setup

```bash
# Install Nix with flakes
sh <(curl -L https://nixos.org/nix/install) --daemon

# Clone and enter
git clone https://github.com/J27REPO/nix.git
cd nix

# Build for your host
sudo nixos-rebuild switch --flake .#laptop
```

## Rebuild

```bash
# From any directory
sudo nixos-rebuild switch --flake ~/nix#$(hostname) --impure

# Or use the reload alias (defined in core.nix)
reload
```

## Key Configs

| File | Purpose |
|------|---------|
| `flake.nix` | Nixpkgs inputs, host definitions |
| `hosts/laptop/default.nix` | AMD GPU, power management, thermald |
| `hosts/macmini/default.nix` | Sunshine, Letta, Docker |
| `modules/core.nix` | Shared services, firewall, flatpak |
| `home/hyprland.nix` | Wayland compositor, workspaces, bindings |

## Versioning

Semantic versioning with automated changelog. See [CHANGELOG.md](CHANGELOG.md).

## License

MIT - Use it as you will.
