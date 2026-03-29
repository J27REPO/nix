---
name: nix-docs
description: Documentation conventions for the NixOS config project
metadata:
  audience: developer
  workflow: nixos
---

## Documentation Rules

### In-Code Comments
- Every non-obvious configuration should have a comment explaining WHY
- Comment format: `# Reason for this config` above the setting
- Keep comments concise, max 1-2 lines unless explaining complex logic

### Module Headers
Each module file should start with a comment block:
```nix
# ─────────────────────────────────────────────
# Module: <module-name>
# Purpose: <what this module configures>
# Host: <laptop | macmini | both>
# ─────────────────────────────────────────────
```

### Package Documentation
When adding packages, update comments listing packages:
```nix
# --- Apps ---
claude-code    # AI coding agent
ncdu           # Disk usage analyzer
# Add new packages here with comment
```

### Bug Fix Documentation
When fixing a bug, add a comment with:
1. What was broken
2. What the fix does
3. Source if applicable (link, issue number, etc.)
```nix
# Fix: USB wakeup causing laptop resurrection after poweroff
# See: https://wiki.nixos.org/...
```

### Config Changes
When changing default values or behavior:
- Leave old commented value for reference
- Add comment explaining why new value was chosen

### README Maintenance
Since this repo is public and serves as inspiration for others, README.md must be kept current:

- Adding new features → Update "Features" section and/or add to structure
- Adding new packages → Add to relevant config file comments (don't list in README)
- Adding new modules → Update structure tree in README
- Changing host configurations → Update "Key Configs" table if relevant
- Bug fixes → No need to update README (CHANGELOG captures this)

The README reflects the current state of the repo; CHANGELOG captures history.

## What NOT to Document
- Obvious settings (no need to comment `enable = true`)
- Standard NixOS defaults
- Self-explanatory options (e.g., `name = "foo"`)

## Example Good Comments
```nix
# GameMode: boosts CPU/GPU for gaming, auto-disables on exit
programs.gamemode.enable = true;

# ZRAM: 35% of RAM as compressed swap (faster than SSD swap, preserves SSD)
zramSwap.memoryPercent = 35;

# Disable USB wakeup to prevent mouse/keyboard from resurrecting sleeping laptop
systemd.services.disable-acpi-wakeup = { ... };
```
