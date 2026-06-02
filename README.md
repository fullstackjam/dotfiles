# Dotfiles

Pure configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

Software installation is handled by [OpenBoot](https://openboot.dev).

## Quick Start

```bash
curl -fsSL openboot.dev/fullstackjam | bash
```

This will:
1. Install Homebrew and packages
2. Clone this repo to `~/.dotfiles`
3. Deploy configs via stow
4. Install Oh-My-Zsh and plugins

## Manual Deploy

```bash
git clone https://github.com/fullstackjam/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow -v --target="$HOME" git ssh zsh claude ghostty
```

## Structure

```
dotfiles/
├── git/.gitconfig                       # Git configuration
├── ssh/.ssh/config                      # SSH client config
├── zsh/.zshrc                           # Zsh configuration
├── claude/.claude/CLAUDE.md             # Claude Code global instructions
├── claude/.claude/settings.json         # Claude Code settings
├── claude/.claude/statusline-command.sh # Claude Code statusline script
└── ghostty/.config/ghostty/config       # Ghostty terminal configuration
```

## How Stow Works

Stow creates symlinks from your home directory to the dotfiles:

```
~/.gitconfig                    → ~/.dotfiles/git/.gitconfig
~/.ssh/config                   → ~/.dotfiles/ssh/.ssh/config
~/.zshrc                        → ~/.dotfiles/zsh/.zshrc
~/.claude/CLAUDE.md             → ~/.dotfiles/claude/.claude/CLAUDE.md
~/.claude/settings.json         → ~/.dotfiles/claude/.claude/settings.json
~/.claude/statusline-command.sh → ~/.dotfiles/claude/.claude/statusline-command.sh
~/.config/ghostty/config        → ~/.dotfiles/ghostty/.config/ghostty/config
```

Note: `~/.claude/` must exist as a real directory before running stow — otherwise stow folds the entire directory into a single symlink. Runtime data (sessions, cache, history, etc.) lives directly in `~/.claude/` and is never tracked.

## License

MIT
