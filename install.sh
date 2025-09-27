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
# 3️⃣ Install oh-my-zsh
# --------------------------
echo "=== 💻 Installing oh-my-zsh ==="
export RUNZSH=no
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed ✅"
fi

# --------------------------
# 4️⃣ Create symbolic links using stow
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

# Use stow to create symbolic links for each configuration directory
for dir in */; do
    if [ -d "$dir" ]; then
        print_status "Linking $dir"
        stow --restow "$dir"
    fi
done

# Special handling for profile files (they need to be in home directory root)
if [ -d "profile" ]; then
    print_status "Linking profile files"
    stow --restow profile
fi

echo "=== ✅ Installation complete, restart terminal to take effect ==="
