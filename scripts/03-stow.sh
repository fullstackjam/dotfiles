#!/bin/bash
# 04-stow.sh - Deploy dotfiles using GNU Stow

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Deploying dotfiles with GNU Stow"

# Get dotfiles directory
DOTFILES_DIR=$(get_dotfiles_dir)

# Check if stow is installed
if ! command_exists stow; then
    print_error "GNU Stow is not installed! Please install it first:"
    print_info "brew install stow"
    exit 1
fi

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Define packages to deploy
PACKAGES=("git" "nvm" "ssh" "nvim")

# Handle command line arguments
if [ -n "$1" ]; then
    # Deploy specific package
    package="$1"
    if directory_exists "$package"; then
        print_info "Deploying $package configuration..."
        if stow --adopt --target="$HOME" "$package"; then
            print_success "$package configuration deployed successfully!"
        else
            print_error "Failed to deploy $package configuration!"
            exit 1
        fi
    else
        print_warning "Package directory '$package' not found, skipping..."
    fi
else
    # Deploy all packages
    for package in "${PACKAGES[@]}"; do
        if directory_exists "$package"; then
            print_info "Deploying $package configuration..."
            if stow --adopt --target="$HOME" "$package"; then
                print_success "$package configuration deployed successfully!"
            else
                print_error "Failed to deploy $package configuration!"
                exit 1
            fi
        else
            print_warning "Package directory '$package' not found, skipping..."
        fi
    done
    print_success "All dotfiles deployed successfully!"
    print_info "You may need to reload your shell: source ~/.zshrc"
fi
