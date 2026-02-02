# Dotfiles

Pure configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

Software installation is handled separately via [OpenBoot](https://openboot.dev).

## Quick Start

```bash
# 1. Install software (via OpenBoot)
curl -fsSL openboot.dev/fullstackjam/dotfiles/install | bash

# 2. Deploy dotfiles
git clone https://github.com/fullstackjam/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make deploy
```

## Commands

```bash
make deploy    # Deploy all dotfiles via stow
make uninstall # Remove deployed dotfiles
make backup    # Backup current dotfiles
make dry-run   # Preview changes without applying
```

## What's Included

| Directory | Description |
|-----------|-------------|
| `git/`    | Git configuration with aliases |
| `ssh/`    | SSH client optimization |
| `zsh/`    | Zsh configuration |
| `npm/`    | NPM configuration |

## How Stow Works

Stow creates symlinks from your home directory to the dotfiles:

```
~/.gitconfig -> ~/.dotfiles/git/.gitconfig
~/.ssh/config -> ~/.dotfiles/ssh/.ssh/config
~/.zshrc -> ~/.dotfiles/zsh/.zshrc
```

## Customization

1. **Git**: Edit `git/.gitconfig` (update name/email)
2. **SSH**: Edit `ssh/.ssh/config`
3. **Zsh**: Edit `zsh/.zshrc`
4. **Add new configs**: Create new directory, add files, update `scripts/03-stow.sh`

## License

MIT
