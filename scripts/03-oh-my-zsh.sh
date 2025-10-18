#!/bin/bash
# 03-oh-my-zsh.sh - Install Oh My Zsh and essential plugins

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Installing Oh My Zsh and Essential Plugins"

# Install Oh My Zsh if not installed
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
if ! directory_exists "$OH_MY_ZSH_DIR"; then
    print_info "Installing Oh My Zsh..."
    if sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        print_success "Oh My Zsh installed successfully!"
    else
        print_error "Failed to install Oh My Zsh!"
        exit 1
    fi
else
    print_success "Oh My Zsh is already installed"
fi

# Install zsh-syntax-highlighting plugin if not installed
SYNTAX_HIGHLIGHTING_DIR="$OH_MY_ZSH_DIR/custom/plugins/zsh-syntax-highlighting"
if ! directory_exists "$SYNTAX_HIGHLIGHTING_DIR"; then
    print_info "Installing zsh-syntax-highlighting plugin..."
    if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"; then
        print_success "zsh-syntax-highlighting plugin installed successfully!"
    else
        print_warning "Failed to install zsh-syntax-highlighting plugin!"
    fi
else
    print_success "zsh-syntax-highlighting plugin is already installed"
fi

# Install zsh-autosuggestions plugin if not installed
AUTOSUGGESTIONS_DIR="$OH_MY_ZSH_DIR/custom/plugins/zsh-autosuggestions"
if ! directory_exists "$AUTOSUGGESTIONS_DIR"; then
    print_info "Installing zsh-autosuggestions plugin..."
    if git clone https://github.com/zsh-users/zsh-autosuggestions.git "$AUTOSUGGESTIONS_DIR"; then
        print_success "zsh-autosuggestions plugin installed successfully!"
    else
        print_warning "Failed to install zsh-autosuggestions plugin!"
    fi
else
    print_success "zsh-autosuggestions plugin is already installed"
fi

print_success "Oh My Zsh and essential plugins installation completed!"
