#!/bin/bash
# 02-brewfile.sh - Install packages from Brewfile

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Installing packages from Brewfile"

# Get dotfiles directory
DOTFILES_DIR=$(get_dotfiles_dir)

# Check if Homebrew is installed
if ! command_exists brew; then
    print_error "Homebrew is not installed! Please run 01-homebrew.sh first."
    exit 1
fi

# Check if Brewfile exists
BREWFILE="$DOTFILES_DIR/Brewfile"
if ! file_exists "$BREWFILE"; then
    print_warning "Brewfile not found at $BREWFILE, skipping package installation"
    exit 0
fi

# Install packages from Brewfile
print_info "Installing packages from Brewfile..."
if brew bundle --file="$BREWFILE"; then
    print_success "All packages from Brewfile installed successfully!"
else
    print_error "Some packages failed to install. Check the output above for details."
    exit 1
fi

print_success "Brewfile installation completed!"
