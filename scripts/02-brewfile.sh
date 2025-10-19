#!/bin/bash
# 02-brewfile.sh - Install packages from Brewfile

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Installing packages from Brewfile"

# Get dotfiles directory
DOTFILES_DIR=$(get_dotfiles_dir)

# Check if Homebrew is installed and load environment
if ! command_exists brew; then
    print_info "Homebrew not found in PATH, attempting to load environment..."
    
    # Try to load Homebrew environment
    if [[ $(uname -m) == "arm64" ]]; then
        # Apple Silicon
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            print_info "Loaded Homebrew environment for Apple Silicon"
        else
            print_error "Homebrew is not installed! Please run 01-homebrew.sh first."
            exit 1
        fi
    else
        # Intel Mac
        if [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
            print_info "Loaded Homebrew environment for Intel Mac"
        else
            print_error "Homebrew is not installed! Please run 01-homebrew.sh first."
            exit 1
        fi
    fi
    
    # Verify brew is now available
    if ! command_exists brew; then
        print_error "Failed to load Homebrew environment!"
        exit 1
    fi
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
