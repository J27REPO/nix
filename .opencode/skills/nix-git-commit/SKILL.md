---
name: nix-git-commit
description: Auto-commit NixOS config changes with semantic versioning and changelog
metadata:
  audience: user
  workflow: nixos
---

## Auto-Commit Workflow

### 1. RUN RELOAD
Use the existing `reload` command which:
- Does `git add .`
- Runs `sudo nixos-rebuild switch --flake ~/nix#$(hostname) --impure`
- Shows fastfetch on success

### 2. ON SUCCESS - Auto Commit
After `reload` succeeds:

1. Run `git status` to see what changed
2. Run `git diff --cached --stat` to get change summary
3. Generate version bump and commit message based on changes:

**Version bump logic:**
- `feat:` changes → MINOR bump (e.g., v1.2.0 → v1.3.0)
- `fix:` changes → PATCH bump (e.g., v1.2.0 → v1.2.1)  
- ONLY `refactor:` or `chore:` → no version bump

**Commit message format:**
```
<type>: <short description>

<detailed changes if needed>

Version: v<major>.<minor>.<patch>
```

4. Run `git commit -m "<message>"` and `git push`

### 3. VERSION FILE
Maintain a `version.txt` in the nix repo root:
```
v1.0.0
```

Read current version before commit, increment appropriately, update the file and commit it too.

### 4. CHANGELOG
Append to `CHANGELOG.md` in the repo root:
```markdown
## [v1.2.0] - YYYY-MM-DD
### Added
- ccache and parallel for faster compilation
- cliphist for Wayland clipboard history
### Fixed
- nvim desktop entry using kitty instead of terminal=true
```

### 5. FILES TO COMMIT
Always commit:
- All modified `.nix` files
- `version.txt` (if changed)
- `CHANGELOG.md` (if changed)

### 6. ON FAILURE
Do NOT commit - fix the issue first using `nix-debug` skill.

## Automation Rules
- NEVER ask for confirmation on commit message
- ALWAYS auto-generate message based on changes
- ALWAYS bump version appropriately
- ALWAYS update CHANGELOG.md
- NEVER push a broken config
