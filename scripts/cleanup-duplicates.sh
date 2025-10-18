#!/bin/bash

# Script to clean up duplicate PATH configurations in .zprofile

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

# Count duplicate PATH lines
snap_lines=$(grep -c "/snap/bin" "$ZPROFILE" 2>/dev/null || echo "0")
local_lines=$(grep -c "\$HOME/.local/bin" "$ZPROFILE" 2>/dev/null || echo "0")

if [ "$snap_lines" -le 1 ] && [ "$local_lines" -le 1 ]; then
    print_success "No duplicate PATH configurations found"
    rm "$BACKUP"
    exit 0
fi

print_warning "Found duplicate PATH configurations (snap: $snap_lines, local: $local_lines)"

# Remove duplicate PATH lines
sed -i '/\/snap\/bin/d' "$ZPROFILE"
sed -i '/\$HOME\/.local\/bin/d' "$ZPROFILE"

# Add single PATH configuration
echo 'export PATH="/snap/bin:$PATH"' >> "$ZPROFILE"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZPROFILE"

print_success "Cleaned up duplicate PATH configurations"
print_info "Backup saved at: $BACKUP"