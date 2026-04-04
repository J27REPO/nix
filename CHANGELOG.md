# Changelog

All notable changes to this NixOS configuration will be documented in this file.

## [v1.9.1] - 2026-04-04
### Fixed
- Security: minimax API key moved from hardcoded keybind to secrets.env (gitignored)

## [v1.9.3] - 2026-04-05
### Fixed
- Security: removed hardcoded OPENAI_API_KEY from home/default.nix, now uses secrets.env

## [v1.9.2] - 2026-04-04
### Fixed
- Neovim: copiar con leader+c o leader+y (space+c, space+y)
- Neovim: fuzzy find con ctrl+f o leader+f
- Neovim: Ctrl+C ya no interceptado (usa leader+c/y en vez de ctrl+c)

## [v1.9.0] - 2026-04-03
### Added
- Zed editor keybind via Super+C (implementation had security issue - fixed in v1.9.1)
- Zathura: PDF viewer with dark theme for viewing Typst PDFs

## [v1.8.0] - 2026-03-30
### Added
- Neovim: telescope-ui-select (mejor UI para selectors)
- Neovim: trouble.nvim (panel de diagnostics)

## [v1.7.0] - 2026-03-30
### Added
- Neovim: todo-comments.nvim (highlights TODO, FIXME, etc.)
- Neovim: render-markdown.nvim (Markdown rendering Obsidian-style)
- Neovim: snacks.nvim (dashboard, indent guides, status column)
- Neovim: nvim-colorizer.lua (hex color preview)
- Neovim: marksman LSP (Markdown language server)
- MuPDF desktop entry for PDF viewing

## [v1.6.0] - 2026-03-30
### Added
- kdePackages.qca (cryptographic support for Okular digital signatures)
- gpgme (GPGME for Okular digital signatures)

## [v1.5.0] - 2026-03-30
### Added
- kdePackages.okular (PDF viewer with digital signature support)
- nss (for certificate management)

## [v1.4.0] - 2026-03-29
### Added
- AMD GPU Overdrive native module (replaces kernel param)
- LACT GPU monitoring service (laptop)
- Firewalld backend migration
- Ccache with compression and prefixed output
- Updated home-manager and zen-browser inputs

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
