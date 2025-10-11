#!/usr/bin/env bash
set -e

# Get script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# --------------------------
# 1️⃣ Install Homebrew
# --------------------------
if ! command -v brew &>/dev/null; then
  echo "=== 🛠 Installing Homebrew ==="
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed ✅"
fi

echo "=== 🍺 Updating Homebrew ==="
brew update

# --------------------------
# 2️⃣ Install all packages (Brewfile)
# --------------------------
echo "=== 📦 Installing Brewfile packages ==="
brew bundle --file="$DOTFILES_DIR/Brewfile"

# --------------------------
# 3️⃣ Check and unlock git-crypt
# --------------------------
print_status "🔐 Checking git-crypt status"

if command -v git-crypt &>/dev/null; then
    # Check if git-crypt is initialized
    if git-crypt status &>/dev/null; then
        # Check if files are already unlocked
        if git-crypt status | grep -q "encrypted"; then
            print_status "🔓 Unlocking git-crypt encrypted files"
            if ! git-crypt unlock; then
                print_error "Failed to unlock git-crypt. Make sure you have the correct GPG key."
                exit 1
            fi
        else
            print_status "Git-crypt files already unlocked ✅"
        fi
    else
        print_warning "Git-crypt not initialized in this repository"
    fi
else
    print_error "git-crypt not found. This should have been installed via Brewfile."
    exit 1
fi

# --------------------------
# 4️⃣ Install oh-my-zsh
# --------------------------
echo "=== 💻 Installing oh-my-zsh ==="
export RUNZSH=no
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed ✅"
fi

# --------------------------
# 5️⃣ Setup SSH directory
# --------------------------
print_status "🔑 Setting up SSH directory"

# Check if .ssh directory exists in dotfiles and is unlocked
if [ -d "$DOTFILES_DIR/.ssh" ]; then
    # Check if SSH files are actually available (not encrypted)
    if [ -f "$DOTFILES_DIR/.ssh/config" ] && [ ! -z "$(cat "$DOTFILES_DIR/.ssh/config" 2>/dev/null | head -1)" ]; then
        print_status "SSH files found and unlocked"

        # Backup existing SSH directory if it exists and is not a symlink
        if [ -d "$HOME/.ssh" ] && [ ! -L "$HOME/.ssh" ]; then
            print_warning "Backing up existing SSH directory to ~/.ssh.backup"
            cp -r "$HOME/.ssh" "$HOME/.ssh.backup"
        fi

        # Remove existing SSH directory if it's a symlink
        if [ -L "$HOME/.ssh" ]; then
            rm -f "$HOME/.ssh"
        fi

        # Create symlink to dotfiles SSH directory
        print_status "Creating symlink: ~/.ssh -> $DOTFILES_DIR/.ssh"
        ln -sf "$DOTFILES_DIR/.ssh" "$HOME/.ssh"

        # Set proper permissions
        chmod 700 "$HOME/.ssh"

        # Set permissions for SSH keys
        for key in "$HOME/.ssh"/id_*; do
            if [ -f "$key" ] && [[ ! "$key" == *.pub ]]; then
                chmod 600 "$key"
                print_status "Set permissions 600 for $(basename "$key")"
            fi
        done

        # Set permissions for public keys
        for pubkey in "$HOME/.ssh"/*.pub; do
            if [ -f "$pubkey" ]; then
                chmod 644 "$pubkey"
                print_status "Set permissions 644 for $(basename "$pubkey")"
            fi
        done

        # Set permissions for config file
        if [ -f "$HOME/.ssh/config" ]; then
            chmod 644 "$HOME/.ssh/config"
        fi

        print_status "SSH directory setup complete ✅"
    else
        print_warning "SSH directory found but files appear to be encrypted. Run 'git-crypt unlock' first."
    fi
else
    print_warning "No .ssh directory found in dotfiles"
fi

# --------------------------
# 6️⃣ Create symbolic links using stow
# --------------------------
print_status "🔗 Creating symbolic links using stow"

# Check if stow is installed
if ! command -v stow &>/dev/null; then
    print_error "stow is not installed. Please install it first:"
    echo "brew install stow"
    exit 1
fi

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Clean up existing links first
print_status "Cleaning up existing links"

# Remove existing dotfiles links
for file in .gitconfig .zshrc .zprofile .nvmrc; do
    if [ -L "$HOME/$file" ]; then
        print_status "Removing existing link: $HOME/$file"
        rm -f "$HOME/$file"
    fi
done

# Remove nvim config directory if it's a link
if [ -L "$HOME/.config/nvim" ]; then
    print_status "Removing existing nvim config link: $HOME/.config/nvim"
    rm -f "$HOME/.config/nvim"
fi

# Remove nvim init.vim if it's a link
if [ -L "$HOME/.config/nvim/init.vim" ]; then
    print_status "Removing existing nvim init.vim link: $HOME/.config/nvim/init.vim"
    rm -f "$HOME/.config/nvim/init.vim"
fi

# Use stow to create symbolic links for each configuration directory (excluding .ssh)
for dir in */; do
    if [ -d "$dir" ] && [ "$dir" != ".ssh/" ]; then
        print_status "Linking $dir"
        stow --target="$HOME" --restow "$dir"
    fi
done

echo "=== ✅ Installation complete, restart terminal to take effect ==="
