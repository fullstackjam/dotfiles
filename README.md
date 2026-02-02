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
stow -v --target="$HOME" git ssh zsh
```

## Structure

```
dotfiles/
├── git/.gitconfig      # Git configuration
├── ssh/.ssh/config     # SSH client config
└── zsh/.zshrc          # Zsh configuration
```

## How Stow Works

Stow creates symlinks from your home directory to the dotfiles:

```
~/.gitconfig    → ~/.dotfiles/git/.gitconfig
~/.ssh/config   → ~/.dotfiles/ssh/.ssh/config
~/.zshrc        → ~/.dotfiles/zsh/.zshrc
```

## License

MIT
