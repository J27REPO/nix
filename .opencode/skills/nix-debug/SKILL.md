---
name: nix-debug
description: Debug NixOS/Nix home-manager issues and fix common errors
metadata:
  audience: developer
  workflow: nixos
---

## Common Errors and Solutions

### "unable to find terminal required for application"
**Cause**: Using `terminal = true` in xdg.desktopEntries without a system terminal launcher
**Fix**: Use `exec = "kitty -e nvim %F"` instead of `terminal = true`

### "Existing file would be clobbered"
**Cause**: Home-manager won't overwrite existing files in ~/.config
**Fix**: Delete the existing file first, or add `force = true` to the xdg.configFile option

### "Home Manager" service failed
**Cause**: Usually from conflicting files or Nix evaluation errors
**Fix**: 
1. Check `systemctl status home-manager-j27` for details
2. Look for evaluation warnings - they often indicate deprecated options
3. Common fix: delete conflicting files in ~/.config (mimeapps.list, gtk-3.0/settings.ini)

### GTK Warnings
- `gtk.gtk4.theme` changed default to `null`: Add `gtk4.theme = config.gtk.theme;` to gtk block
- `home.stateVersion` < "26.05" uses legacy defaults

### Git Signing Warnings
- `programs.git.signing.format` changed: Set `signing.format = "openpgp"` at top level of `programs.git`

## Useful Debug Commands
```bash
# Check home-manager status
systemctl status home-manager-j27

# View full logs
journalctl -u home-manager-j27

# Dry run (just evaluate, don't build)
nix eval ~/nix#nixosConfigurations.laptop.config.system.build.toplevel --json

# List all home-manager generations
ls -la ~/.local/state/home-manager/

# Rollback home-manager
home-manager switch --backup-file ~/.home-manager.backup -b backup --flake ~/nix#laptop
```

## Safe Editing Practice
1. Make small changes
2. Rebuild immediately
3. If it fails, use `/undo` and fix before continuing
