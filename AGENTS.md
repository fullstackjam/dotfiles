# PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-01
**Commit:** 8983e13
**Branch:** master

## OVERVIEW

macOS dotfiles manager using GNU Stow + Make. Symlinks configs from repo dirs to `$HOME`.

## STRUCTURE

```
dotfiles/
├── Makefile              # Entry point: make setup/install/deploy
├── Brewfile              # Homebrew packages (50+ CLI/GUI)
├── scripts/              # Numbered install scripts (01-05)
│   └── common.sh         # Shared utilities (source this)
├── git/.gitconfig        # Git config (stow → ~/.gitconfig)
├── ssh/.ssh/config       # SSH config (stow → ~/.ssh/config)
├── zsh/.zshrc            # ZSH config (stow → ~/.zshrc)
└── npm/package.json      # Global npm packages
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add Homebrew package | `Brewfile` | `brew` for CLI, `cask` for GUI |
| Add npm package | `npm/package.json` | Installed globally via script |
| Modify shell | `zsh/.zshrc` | Oh My ZSH + 7 plugins |
| Add new config type | Create `foo/.foorc`, update `scripts/03-stow.sh` PACKAGES array |
| macOS preferences | `scripts/04-configure-macos.sh` | Dock, trackpad, login items |
| Change install order | `Makefile` dependencies | Scripts numbered for order |

## CONVENTIONS

**Script Naming**: `NN-description.sh` — Number = execution order dependency
**Stow Package Structure**: `{name}/.{name}rc` or `{name}/.{name}/config` mirrors `$HOME`
**Shared Functions**: All scripts `source "$SCRIPT_DIR/common.sh"` for utilities
**Output Colors**: `print_info/success/warning/error/step/header` from common.sh

## ANTI-PATTERNS (THIS PROJECT)

**NEVER**:
- Run `04-configure-macos.sh` without reviewing app config at top of file (DOCK_APPS, LOGIN_APPS)
- `eval "$cmd"` in `common.sh:69` — code injection if untrusted input
- `defaults delete` in `04-configure-macos.sh` — destructive, no rollback

**MITIGATED** (previously dangerous, now fixed):
- Remote scripts now download first, then execute (no direct `curl | bash`)
- Stow now backs up existing files to `~/.dotfiles-backup/` before overwriting
- Homebrew env setup is now idempotent (uses marker comment check)

## COMMANDS

```bash
# Full setup (requires macOS)
make setup           # install + deploy + configure

# Modular
make install         # Homebrew → Brewfile → npm packages
make deploy          # Oh My ZSH → Stow all configs
make configure       # macOS Dock/trackpad/login items

# Individual
make homebrew        # Install Homebrew only
make brewfile        # Install Brewfile packages
make npm             # Install global npm packages
make oh-my-zsh       # Install Oh My ZSH + plugins
make stow-git        # Deploy git config only
make stow-ssh        # Deploy ssh config only
make stow-zsh        # Deploy zsh config only

# Maintenance
make uninstall       # Remove stow symlinks
make backup          # Backup dotfiles to ~/.dotfiles-backup
make dry-run         # Preview stow changes
```

## NOTES

- **macOS only**: Scripts check `is_macos()` and exit on other platforms
- **Apple Silicon aware**: Homebrew path auto-detected (`/opt/homebrew` vs `/usr/local`)
- **1Password SSH**: `ssh/.ssh/config` uses 1Password agent for key management
- **GitHub SSH**: Port 443 via `ssh.github.com` (bypasses firewall restrictions)
- **Oh My ZSH plugins**: 4 custom (autosuggestions, syntax-highlighting x2, autocomplete) + 3 builtin (git, helm, kubectl)
- **Git user**: Hardcoded to `fullstackjam` — update `git/.gitconfig` before first use
- **No editor configs**: vim/neovim/vscode settings not managed here
