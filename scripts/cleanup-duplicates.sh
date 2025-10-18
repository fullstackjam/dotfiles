#!/bin/bash

# Script to clean up duplicate Homebrew configurations in .zprofile

ZPROFILE="$HOME/.zprofile"
BACKUP="$HOME/.zprofile.backup.$(date +%Y%m%d_%H%M%S)"

print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

# Check if .zprofile exists
if [ ! -f "$ZPROFILE" ]; then
    print_warning ".zprofile not found at $ZPROFILE"
    exit 0
fi

# Create backup
cp "$ZPROFILE" "$BACKUP"
print_info "Created backup: $BACKUP"

# Count duplicate lines
brew_lines=$(grep -c "brew shellenv" "$ZPROFILE" 2>/dev/null || echo "0")

if [ "$brew_lines" -le 1 ]; then
    print_success "No duplicate Homebrew configurations found"
    rm "$BACKUP"
    exit 0
fi

print_warning "Found $brew_lines duplicate Homebrew configurations"

# Remove all brew shellenv lines
sed -i '' '/brew shellenv/d' "$ZPROFILE"

# Add single Homebrew configuration
if [[ $(uname -m) == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$ZPROFILE"
    print_info "Added Apple Silicon Homebrew configuration"
else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$ZPROFILE"
    print_info "Added Intel Mac Homebrew configuration"
fi

print_success "Cleaned up duplicate Homebrew configurations"
print_info "Backup saved at: $BACKUP"
