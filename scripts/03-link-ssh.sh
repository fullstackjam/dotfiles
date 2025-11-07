#!/bin/bash
# 03-link-ssh.sh - Symlink SSH configuration

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Linking SSH configuration"

# Get dotfiles directory
DOTFILES_DIR=$(get_dotfiles_dir)
SOURCE_CONFIG="$DOTFILES_DIR/ssh/.ssh/config"
TARGET_DIR="$HOME/.ssh"
TARGET_CONFIG="$TARGET_DIR/config"

if [ ! -f "$SOURCE_CONFIG" ]; then
    print_warning "SSH config not found at $SOURCE_CONFIG; skipping link"
    exit 0
fi

# Ensure ~/.ssh exists
if [ ! -d "$TARGET_DIR" ]; then
    print_info "Creating $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    chmod 700 "$TARGET_DIR"
fi

# Backup existing config if it exists and is not already the desired symlink
if [ -e "$TARGET_CONFIG" ] && [ ! -L "$TARGET_CONFIG" -o "$(readlink "$TARGET_CONFIG")" != "$SOURCE_CONFIG" ]; then
    BACKUP="$TARGET_CONFIG.backup.$(date +%Y%m%d%H%M%S)"
    print_info "Backing up existing SSH config to $BACKUP"
    mv "$TARGET_CONFIG" "$BACKUP"
fi

print_info "Linking $SOURCE_CONFIG -> $TARGET_CONFIG"
ln -sfn "$SOURCE_CONFIG" "$TARGET_CONFIG"

print_success "SSH configuration linked successfully!"
