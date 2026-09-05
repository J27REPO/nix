# NixOS Dotfiles

My NixOS configuration with Hyprland, optimized for laptop and macmini.

## Structure

```
nix/
├── flake.nix              # Main flake (inputs, outputs, mkHost)
├── flake.lock             # Locked versions
├── version.txt            # Current version (v1.11.0)
├── CHANGELOG.md           # Version history
├── README.md              # This file
├── home/                  # Home-manager user config
│   ├── default.nix        # Main HM config
│   ├── hyprland.nix       # Hyprland window manager
│   ├── nvchad.nix         # Neovim NvChad config
│   └── mime-apps.nix      # Desktop entries & MIME
├── hosts/
│   ├── laptop/default.nix # Laptop-specific config
│   └── macmini/default.nix # Mac Mini-specific config
├── modules/
│   └── core.nix           # Shared modules (boot, networking, etc.)
└── pkgs/
    └── rustnet.nix        # Rustnet package (buildRustPackage)
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

## Precompiled Binaries (JiruHub)

NixOS no sigue FHS, por lo que binarios precompilados como **JiruHub** (app Flutter/GTK) no encuentran sus librerías. La solución usa dos mecanismos:

### nix-ld (sistema)

`programs.nix-ld.enable = true` en `modules/core.nix` crea un linker que busca librerías en `/run/current-system/sw/share/nix-ld/lib/`. Las librerías necesarias se declaran en `programs.nix-ld.libraries`.

### Wrapper script (~/.local/bin/jiruhub)

Algunas librerías (como `zlib` 32-bit) pueden pisar a las de 64-bit en el flat dir de nix-ld. El wrapper resuelve esto anteponiendo la ruta 64-bit en `LD_LIBRARY_PATH`:

```bash
export LD_LIBRARY_PATH="$ZLIB64:$NIX_LD_LIB:$JIRUHUB_LIB"
exec "$JIRUHUB_BIN" "$@"
```

### Para añadir un nuevo binario precompilado

1. Agrega las librerías que necesita a `programs.nix-ld.libraries` en `modules/core.nix`
2. Si hay conflicto 32/64-bit, crea un wrapper en `~/.local/bin/` similar al de JiruHub
3. Asegúrate de que `~/.local/bin/` esté en el PATH (via `home.sessionVariables` o `initContent` en `home/default.nix`)

## Key Configs

| File | Purpose |
|------|---------|
| `flake.nix` | Nixpkgs inputs, host definitions |
| `hosts/laptop/default.nix` | AMD GPU, power management, thermald |
| `hosts/macmini/default.nix` | Sunshine, Letta, Docker |
| `modules/core.nix` | Shared services, firewall, flatpak |
| `home/hyprland.nix` | Wayland compositor, workspaces, bindings |
| `pkgs/rustnet.nix` | Rustnet package (buildRustPackage, eBPF enabled) |

## Packages from Source

### rustnet
Per-process network monitor TUI with deep packet inspection. Built from `github:domcyrus/rustnet` via `buildRustPackage`. Requires `sudo` for packet capture:

```bash
sudo rustnet
# Or grant capabilities:
sudo setcap 'cap_net_raw,cap_bpf,cap_perfmon+eip' $(which rustnet)
rustnet
```

## Versioning

Semantic versioning with automated changelog. See [CHANGELOG.md](CHANGELOG.md).

## License

MIT - Use it as you will.
