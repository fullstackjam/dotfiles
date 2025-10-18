# Dotfiles

A clean, modular dotfiles management system using GNU Stow and Make, adapted for Ubuntu.

## 🚀 Quick Start

```bash
git clone https://github.com/fullstackjam/dotfiles.git
cd dotfiles
make setup
```

## 📋 Commands

```bash
make setup       # Complete installation + deployment
make install     # Install software only
make deploy      # Deploy dotfiles only

# Modular options
make packages    # Install packages from packages.txt
make oh-my-zsh   # Install Oh My Zsh + plugins
make stow-git    # Deploy Git config only
make stow-zsh    # Deploy Zsh config only
make stow-nvm    # Deploy NVM config only
make stow-ssh    # Deploy SSH config only
make stow-nvim   # Deploy Neovim config only
make cleanup     # Clean up duplicate configurations

make help        # Show all commands
```

## 📦 What's Included

- **APT/Snap** package management
- **Oh My Zsh** with syntax highlighting & autosuggestions
- **Git** configuration with useful aliases
- **Zsh** shell configuration
- **SSH** client optimization
- **NVM** Node.js version management
- **Neovim** modern editor with essential plugins

## 🏗️ Architecture

```
dotfiles/
├── Makefile              # Main interface
├── scripts/              # Modular installation scripts
├── git/                  # Git configuration
├── zsh/                  # Zsh configuration
├── nvm/                  # Node.js version
├── ssh/                  # SSH configuration
├── nvim/                 # Neovim configuration
└── packages.txt          # Ubuntu packages list
```

## 🔧 Customization

**Configure Git**: Edit `git/.gitconfig` and uncomment/update name/email
**Add packages**: Edit `packages.txt`
**Modify configs**: Edit files in respective directories
**Add new configs**: Create new directory and update `scripts/04-stow.sh`

## 📄 License

MIT