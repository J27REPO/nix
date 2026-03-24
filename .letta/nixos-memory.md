# NixOS Configuration Memory

## Estructura del repo
```
~/nix/
├── flake.nix          # Entry point principal
├── flake.lock         # Lock file de inputs
├── home/              # Configuración de usuario (home-manager)
├── hosts/             # Configuraciones de máquinas específicas
│   └── laptop/        # Configuración de laptop
├── modules/           # Módulos reutilizables
│   └── core.nix       # Configuración base del sistema
└── .letta/            # Memorias de configuración
    └── nixos-memory.md # Este archivo
```

## Comandos útiles
- `reload` - Script personalizado para reconstruir NixOS (definido en `modules/core.nix`)
- `sudo nixos-rebuild switch --flake ~/nix#laptop --impure` - Rebuild manual
- `update` - Alias para rebuild con hostname automático

## Errores comunes y soluciones

### Error: "undefined variable 'lib32'"
**Problema:** Se usaba `lib32` directamente en el contexto de NixOS.
**Solución:** Usar `pkgs.pkgsi686Linux` para acceder a librerías 32-bit.

```nix
# INCORRECTO:
lib32.vulkan-loader
lib32.libglvnd

# CORRECTO:
pkgs.pkgsi686Linux.vulkan-loader
pkgs.pkgsi686Linux.libglvnd
```

### Error: "attribute 'libdbus' missing"
**Problema:** El paquete se llama `dbus`, no `libdbus`.
**Solución:**
```nix
pkgs.pkgsi686Linux.dbus  # No libdbus
```

## Gaming: Lutris + Wine

### Configuración actual (home/default.nix)
- Lutris instalado directamente de nixpkgs
- `protonup-qt` para gestionar runtimes de Wine-GE/Proton
- GameMode habilitado para optimizaciones de gaming

### Error: "Proton is not compatible with 32-bit prefixes"
**Problema:** Se usaba Proton como runner pero el prefijo estaba en win32.
**Solución:**
1. Cambiar runner de Proton a **Wine-GE** (descargado via protonup-qt)
2. Usar prefijo **Windows 64-bit**

### Error: Wine nativo falla con exit code 13568
**Problema:** El wine nativo de nixpkgs (`wineWow64Packages.stable`) no tiene todas las dependencias para juegos.
**Solución:** Usar **Lutris-GE-Proton** (descargado con protonup-qt) como runner en vez de Wine nativo.

### Flujo para configurar juego en Lutris
1. Ejecutar `protonup-qt` → descargar versión Wine-GE (ej: GE-Proton8-26)
2. En Lutris, configurar juego:
   - **Runner**: Lutris-GE-Proton (NO Wine nativo NI Proton de Steam)
   - **Prefijo**: Windows 64-bit
   - **Arquitectura**: win64
3. El prefijo corruptos eliminar: `rm -rf ~/Documents/isaac/isaac_prefix`

## Servicios habilitados
- PipeWire (audio) con soporte 32-bit
- Bluetooth con powerOnBoot
- Docker
- Flatpak
- SDDM (Wayland)
- Hyprland (Wayland compositor)
- Gvfs/Udisks2 (montaje de dispositivos)
- GameMode (gamemoded)
- Tailscale (VPN)
- Avahi (mDNS)

## Configuración especial
- WiFi/Bluetooth firmware redistribuible habilitado
- Auto-login para usuario `j27`
- Lid switch → suspend
- Power key → hibernate
- Swappiness baja (10) para SSD + 16GB RAM
- Journal limitado a 500MB
- Nix garbage collector semanal (borrar >7 días)
- ZRAM habilitado con algoritmo zstd
- amd_pstate=active para gestión de energía AMD
