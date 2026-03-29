---
name: nix-workflow
description: Automated workflow: edit NixOS config → reload → if success auto-commit/push, if fail fix error
metadata:
  audience: user
  workflow: nixos
---

## Complete Workflow (execute in order)

### 1. MAKE CHANGES
Edit the necessary .nix files following conventions in `nix-edit` skill.

### 2. UPDATE DOCUMENTATION
After making changes, update relevant docs:
- If you added a package: document it in the code comments
- If you changed a config section: update any comments explaining it
- If you fixed a bug: add a comment explaining the fix
- If you added a new module: add it to the imports list with explanation
- If you added new features or changed structure: update README.md (see `nix-docs` skill)
- Update CHANGELOG.md with the changes

### 3. REBUILD
Use the `reload` command (already includes git add + rebuild):
```bash
reload
```
This command:
1. Runs `git add .` in ~/nix
2. Runs `sudo nixos-rebuild switch --flake ~/nix#$(hostname) --impure`
3. Shows fastfetch on success

### 4. IF REBUILD SUCCEEDS
1. Run `git status` and `git diff --cached --stat` to see changes
2. Determine version bump:
   - `feat:` changes → MINOR bump
   - `fix:` changes → PATCH bump
   - Only refactor/chore → no bump
3. Read current version from `version.txt`
4. Generate and run commit with message:
   ```
   <type>: <short description>
   
   Version: v<major>.<minor>.<patch>
   ```
5. Update `version.txt` if bumped
6. Append to `CHANGELOG.md`
7. Run `git push`

### 5. IF REBUILD FAILS
1. Read the error output carefully
2. Common fixes (see `nix-debug` skill):
   - **"Existing file would be clobbered"**: Delete the conflicting file in `~/.config/`
   - **"unable to find terminal"**: Use `exec = "kitty -e nvim %F"` instead of `terminal = true`
   - **GTK/Git warnings**: Add the recommended options to silence them
3. Fix the issue in the appropriate .nix file
4. Retry rebuild with `reload`
5. Repeat until success

### 6. FINALLY
Tell the user the system is ready with the new changes and version.

## Automation Rules
- ALWAYS use `reload` for rebuild (don't manually run nixos-rebuild)
- ALWAYS attempt auto-fix on failure before asking user
- NEVER ask for confirmation on commit message
- ALWAYS auto-generate version bump and changelog entry
- ALWAYS update README.md if new features or structural changes
- NEVER push a broken configuration
