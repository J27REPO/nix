---
name: nix-rebuild
description: Rebuild NixOS configuration with home-manager. Use after editing any .nix files in ~/nix/
metadata:
  audience: user
  workflow: nixos
---

## When to Use
After editing any file in ~/nix/ (flake.nix, home/*.nix, hosts/*.nix, modules/*.nix)

## How to Rebuild
```
cd ~/nix && sudo nixos-rebuild switch --flake ~/nix#hostname --impure
```
Where `hostname` is `laptop` or `macmini`

Note: `--impure` is required because the flake imports `/etc/nixos/hardware-configuration.nix` which is an absolute path.

## After Rebuild
Always run `/home/j27/nix` and tell the user if there are warnings or errors

## Warnings to Fix
- `gtk.gtk4.theme = config.gtk.theme` to silence gtk4 warning
- `signing.format = "openpgp"` at top level of `programs.git` to silence git warning
- Use `force = true` on xdg.configFile options when overwriting existing files
