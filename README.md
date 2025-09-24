# Dotfiles

Personal dotfiles configuration for macOS development environment.

## Structure

```
dotfiles/
├── Brewfile              # Homebrew packages and casks
├── install.sh            # Automated installation script
├── zsh/
│   └── .zshrc           # Zsh configuration with oh-my-zsh
├── git/
│   └── .gitconfig       # Git configuration
└── nvim/
    └── .config/nvim/init.vim  # Neovim configuration
```

## Installation

1. Clone this repository to your home directory:
   ```bash
   git clone <repository-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Make the install script executable and run it:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. Restart your terminal to apply all changes.

## What's Included

### Homebrew Packages
- **Essential CLI tools**: git, zsh, stow, nvim, curl, wget, jq, yq, tree, htop, fzf, ripgrep, fd
- **Development tools**: kubectl, helm, pyenv, pyenv-virtualenv, node, python@3.11
- **Zsh plugins**: zsh-syntax-highlighting, zsh-autosuggestions
- **GUI applications**: Warp, 1Password, Visual Studio Code, Cursor, Postman, Typora, Maccy, Notion, OrbStack, NetEase Music

### Configuration Files
- **Zsh**: oh-my-zsh with useful plugins, aliases, custom functions, and history management
- **Git**: Configured with useful aliases, colors, merge tools, and modern defaults
- **Neovim**: Modern Vim configuration with syntax highlighting, better navigation, and key mappings

## Usage

The dotfiles are managed using GNU Stow, which creates symbolic links from your home directory to the configuration files in this repository. This allows you to:

- Keep all your dotfiles in version control
- Easily sync configurations across machines
- Maintain a clean home directory structure
- Automatically handle directory creation and linking

## Customization

To add new configurations:
1. Create a new directory for your tool (e.g., `tmux/`)
2. Add your configuration files with a dot prefix (e.g., `tmux/.tmux.conf`)
3. Re-run the installation script (stow will automatically handle the new directory)

To update existing configurations, simply edit the files in this repository and the changes will be reflected in your home directory.

## Features

- **Automated setup**: One command installs everything
- **Modern tools**: Latest versions of essential development tools
- **Cross-platform**: Works on macOS (with Homebrew)
- **Version controlled**: All configurations tracked in Git
- **Easy maintenance**: Simple to update and sync across machines