#!/bin/bash
# 05-npm-packages.sh - Install global npm packages for AI CLI tools

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Installing npm packages for AI CLI tools"

# Get dotfiles directory
DOTFILES_DIR=$(get_dotfiles_dir)
NPM_DIR="$DOTFILES_DIR/npm"

# Check if node is installed
if ! command_exists node; then
    print_error "Node.js is not installed! Please run 'make brewfile' first."
    exit 1
fi

print_info "Node.js version: $(node --version)"
print_info "npm version: $(npm --version)"

# Check if npm directory exists
if ! directory_exists "$NPM_DIR"; then
    print_error "npm directory not found at $NPM_DIR"
    exit 1
fi

# Check if package.json exists
if ! file_exists "$NPM_DIR/package.json"; then
    print_error "package.json not found at $NPM_DIR/package.json"
    exit 1
fi

# Install packages globally from package.json
print_info "Installing global npm packages..."

# Read dependencies from package.json and install globally
cd "$NPM_DIR"

# Extract package names from package.json and install globally
packages=$(node -e "
const pkg = require('./package.json');
const deps = pkg.dependencies || {};
console.log(Object.keys(deps).join(' '));
")

if [ -z "$packages" ]; then
    print_warning "No packages to install"
    exit 0
fi

print_info "Installing: $packages"

for package in $packages; do
    print_info "Installing $package globally..."
    if npm install -g "$package"; then
        print_success "$package installed successfully!"
    else
        print_warning "Failed to install $package, continuing..."
    fi
done

# Verify installations
print_info "Verifying installations..."

if command_exists claude; then
    print_success "claude-code: $(claude --version 2>/dev/null || echo 'installed')"
else
    print_warning "claude command not found in PATH"
fi

if command_exists codex; then
    print_success "codex: $(codex --version 2>/dev/null || echo 'installed')"
else
    print_warning "codex command not found in PATH"
fi

# Install Claude Code using official install script
print_info "Installing Claude Code via official install script..."
if curl -fsSL https://claude.ai/install.sh | bash; then
    print_success "Claude Code installed successfully!"
else
    print_warning "Failed to install Claude Code"
fi

print_success "npm packages installation completed!"
