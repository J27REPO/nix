# Changelog

All notable changes to this NixOS configuration will be documented in this file.

## [v1.3.0] - 2026-03-28
### Added
- Sysctl tuning: sched_autogroup, sched_migration_cost, inotify watches, TCP fastopen

## [v1.2.1] - 2026-03-28
### Fixed
- wlsunset command flags corrected (removed invalid -m flag)

## [v1.2.0] - 2026-03-28
### Added
- wlsunset package for automatic gamma control
- Expanded mako notifications (icons, sound, layer, urgency levels)
### Fixed
- Timezone set to Europe/Madrid (was UTC)

## [v1.1.0] - 2026-03-28
### Added
- Optimization packages: ccache, parallel (faster compilation)
- Wayland clipboard tools: cliphist
- waylock (minimalist lock screen)
- Early KMS for faster AMD GPU boot
- nix.auto-optimise-store enabled
- OpenCode skills: nix-workflow, nix-git-commit, nix-edit, nix-debug, nix-docs, nix-rebuild
### Fixed
- nvim desktop entry now uses kitty -e instead of terminal=true (fixes "unable to find terminal" error)
- gtk4.theme warning silenced
- git signing.format warning silenced

## [v1.0.0] - 2026-03-28
### Added
- Initial NixOS configuration with Hyprland, Wayland, and home-manager
- Shared config between laptop and macmini via ~/nix flake
- kitty, zsh, starship, neovim (NvChad) setup
- Android development environment (Android SDK, Java, Gradle)
- Gaming support (Wine, Gamemode, Moonlight)
- Media apps (mpv, zotero, obsidian)
- Wayland utilities (swww, grim, slurp, wl-clipboard)
- System optimizations (zram, auto-cpufreq, thermald)
- Home Manager for user configuration
- Thunar file manager with custom MIME associations
