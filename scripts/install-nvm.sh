#!/bin/bash
# install-nvm.sh - Install nvm (Node Version Manager) properly

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Installing nvm (Node Version Manager)"

# Check if nvm is already installed
if [ -d "$HOME/.nvm" ]; then
    print_info "nvm is already installed, do nothing..."
else
    print_info "Installing nvm from official script..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash || {
        print_error "Failed to install nvm"
        exit 1
    }
fi

# Source nvm in current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Add nvm to shell profile
SHELL_PROFILE=""
if [ -f "$HOME/.zprofile" ]; then
    SHELL_PROFILE="$HOME/.zprofile"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
else
    SHELL_PROFILE="$HOME/.zprofile"
    touch "$SHELL_PROFILE"
fi

# Add nvm configuration to shell profile if not already present
if ! grep -q "NVM_DIR" "$SHELL_PROFILE" 2>/dev/null; then
    echo "" >> "$SHELL_PROFILE"
    echo "# nvm configuration" >> "$SHELL_PROFILE"
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$SHELL_PROFILE"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$SHELL_PROFILE"
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$SHELL_PROFILE"
    print_info "Added nvm configuration to $SHELL_PROFILE"
else
    print_info "nvm configuration already present in $SHELL_PROFILE"
fi

# Install latest LTS Node.js if not already installed
print_info "Checking for latest LTS Node.js..."
nvm install

print_success "nvm installation completed!"
print_info "You can now use 'nvm install <version>' to install specific Node.js versions"
print_info "Use 'nvm list' to see installed versions"
print_info "Use 'nvm use <version>' to switch between versions"
print_info "nvm will automatically use .nvmrc file if present in your project directory"
