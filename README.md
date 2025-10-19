# Dotfiles

A clean, modular dotfiles management system using GNU Stow and Make.

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
make homebrew    # Install Homebrew
make brewfile    # Install packages
make stow-git    # Deploy Git config only
make stow-nvm    # Deploy NVM config only
make stow-ssh    # Deploy SSH config only
make stow-nvim   # Deploy Neovim config only

make help        # Show all commands
```

## 📦 What's Included

- **Homebrew** package manager with 50+ packages
- **Git** configuration with useful aliases and colors
- **SSH** client optimization for GitHub and general use
- **NVM** Node.js version management
- **Neovim** modern editor with essential plugins

## 🏗️ Architecture

```
dotfiles/
├── Makefile              # Main interface
├── scripts/              # Modular installation scripts
├── git/                  # Git configuration
├── nvm/                  # Node.js version management
├── ssh/                  # SSH configuration
├── nvim/                 # Neovim configuration
└── Brewfile              # Homebrew packages
```

## 🔧 Customization

**Configure Git**: Edit `git/.gitconfig` and uncomment/update name/email
**Add packages**: Edit `Brewfile`
**Modify configs**: Edit files in respective directories
**Add new configs**: Create new directory and update `scripts/03-stow.sh`

## 📄 License

MIT