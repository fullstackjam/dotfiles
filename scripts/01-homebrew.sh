#!/bin/bash
# 01-homebrew.sh - Install Homebrew package manager

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Installing Homebrew"

# Check if running on macOS
if ! is_macos; then
    print_error "This script is designed for macOS only!"
    exit 1
fi

# Install Homebrew (includes environment setup)
install_homebrew

print_success "Homebrew installation completed!"
