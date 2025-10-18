#!/bin/bash
# 01-packages.sh - Install packages for Ubuntu

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Installing packages for Ubuntu"

# Check if running on Ubuntu
if ! is_ubuntu; then
    print_error "This script is designed for Ubuntu only!"
    exit 1
fi

# Get dotfiles directory
DOTFILES_DIR=$(get_dotfiles_dir)

# Install essential packages first
install_essential_packages

# Check if packages.txt exists
PACKAGES_FILE="$DOTFILES_DIR/packages.txt"
if ! file_exists "$PACKAGES_FILE"; then
    print_warning "packages.txt not found at $PACKAGES_FILE, skipping package installation"
    exit 0
fi

# Install packages from packages.txt
print_info "Installing packages from packages.txt..."

# Filter out comments and empty lines, then install packages
while IFS= read -r package; do
    # Skip comments and empty lines
    if [[ "$package" =~ ^[[:space:]]*# ]] || [[ -z "${package// }" ]]; then
        continue
    fi
    
    # Install package
    if ! command_exists "$package"; then
        print_info "Installing $package..."
        if sudo apt install -y "$package"; then
            print_success "$package installed successfully!"
        else
            print_warning "Failed to install $package"
        fi
    else
        print_success "$package is already installed"
    fi
done < "$PACKAGES_FILE"

# Setup Ubuntu environment
setup_ubuntu_env

print_success "Package installation completed!"
