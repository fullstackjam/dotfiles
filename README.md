# Dotfiles

A minimal setup for provisioning a new macOS machine with a few Homebrew apps and your SSH configuration.

## 🚀 Quick Start

```bash
git clone https://github.com/fullstackjam/dotfiles.git
cd dotfiles
make setup
```

## 📋 Commands

```bash
make setup      # Install Homebrew, Brewfile packages, link SSH config, and apply macOS prefs

# Modular options
make homebrew   # Install Homebrew
make brewfile   # Install packages from Brewfile
make link-ssh   # Symlink ssh/.ssh/config to ~/.ssh/config
make macos      # Apply Dock, trackpad, and login item settings

make help       # Show all commands
```

## 📦 What's Included

- **Homebrew** bootstrap script
- **Brewfile** with a curated set of GUI tools
- **SSH** configuration (symlinked into place)
- **macOS preferences** script (Dock, Trackpad, login items)

## 🏗️ Structure

```
dotfiles/
├── Brewfile              # Homebrew packages
├── Makefile              # Minimal task runner
├── scripts/              # Installation/link scripts
└── ssh/                  # SSH configuration to be linked
```

## 🔧 Customization

- Edit `Brewfile` to add or remove Homebrew packages
- Update `ssh/.ssh/config` with your preferred hosts
- Adjust `scripts/03-link-ssh.sh` if you want a different linking strategy
- Adjust `scripts/04-configure-macos.sh` to tweak Dock/Trackpad/login items

## 📄 License

MIT