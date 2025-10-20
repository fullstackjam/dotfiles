#!/bin/bash
# install-oh-my-zsh.sh - Install Oh My ZSH with essential plugins

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Installing Oh My ZSH with plugins"

# Check if running on macOS
if ! is_macos; then
    print_error "This script is designed for macOS only!"
    exit 1
fi

# Check if zsh is installed
if ! command_exists zsh; then
    print_info "Installing zsh..."
    brew install zsh || {
        print_error "Failed to install zsh"
        exit 1
    }
else
    print_info "zsh is already installed"
fi

# Check if Oh My ZSH is already installed
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_info "Oh My ZSH is already installed, updating..."
    # Update Oh My ZSH
    cd "$HOME/.oh-my-zsh"
    git pull origin master || {
        print_warning "Failed to update Oh My ZSH, but it's already installed"
    }
else
    print_info "Installing Oh My ZSH..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        print_error "Failed to install Oh My ZSH"
        exit 1
    }
fi

# Install plugins
print_info "Installing Oh My ZSH plugins..."

# Create plugins directory if it doesn't exist
ZSH_CUSTOM_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
mkdir -p "$ZSH_CUSTOM_PLUGINS"

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" ]; then
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" || {
        print_error "Failed to install zsh-autosuggestions"
        exit 1
    }
else
    print_info "zsh-autosuggestions is already installed"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting" ]; then
    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting" || {
        print_error "Failed to install zsh-syntax-highlighting"
        exit 1
    }
else
    print_info "zsh-syntax-highlighting is already installed"
fi

# Install fast-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM_PLUGINS/fast-syntax-highlighting" ]; then
    print_info "Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM_PLUGINS/fast-syntax-highlighting" || {
        print_error "Failed to install fast-syntax-highlighting"
        exit 1
    }
else
    print_info "fast-syntax-highlighting is already installed"
fi

# Install zsh-autocomplete
if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autocomplete" ]; then
    print_info "Installing zsh-autocomplete..."
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM_PLUGINS/zsh-autocomplete" || {
        print_error "Failed to install zsh-autocomplete"
        exit 1
    }
else
    print_info "zsh-autocomplete is already installed"
fi

# Instructions for manual setup
print_success "Oh My ZSH installation completed!"
