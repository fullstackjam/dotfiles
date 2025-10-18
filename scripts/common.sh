#!/bin/bash
# common.sh - Shared functions and utilities for dotfiles installation

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a directory exists
directory_exists() {
    [ -d "$1" ]
}

# Function to check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Function to get the dotfiles directory
get_dotfiles_dir() {
    # Get the directory where this script is located
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Return the parent directory (dotfiles root)
    echo "$(dirname "$script_dir")"
}

# Function to run a command with error handling
run_command() {
    local cmd="$1"
    local description="${2:-Running command}"
    
    print_info "$description..."
    if eval "$cmd"; then
        print_success "$description completed successfully!"
        return 0
    else
        print_error "$description failed!"
        return 1
    fi
}

# Function to install essential packages if not installed
install_essential_packages() {
    print_info "Installing essential packages..."
    
    # Update package list
    run_command "sudo apt update" "Updating package list"
    
    # Install essential packages
    local essential_packages="curl wget git stow zsh neovim"
    run_command "sudo apt install -y $essential_packages" "Installing essential packages"
    
    print_success "Essential packages installed successfully!"
    return 0
}

# Function to check if running on Ubuntu
is_ubuntu() {
    [[ -f /etc/os-release ]] && grep -q "Ubuntu" /etc/os-release
}

# Function to check if running on ARM64
is_arm64() {
    [[ $(uname -m) == "aarch64" ]]
}

# Function to check if running on x86_64
is_x86_64() {
    [[ $(uname -m) == "x86_64" ]]
}

# Function to setup Ubuntu environment
setup_ubuntu_env() {
    print_info "Setting up Ubuntu environment..."
    
    # Add snap to PATH if not already there
    if ! grep -q "/snap/bin" ~/.zprofile 2>/dev/null; then
        echo 'export PATH="/snap/bin:$PATH"' >> ~/.zprofile
        print_info "Added snap to PATH in ~/.zprofile"
    else
        print_info "snap already configured in ~/.zprofile"
    fi
    
    # Add snap to current session
    export PATH="/snap/bin:$PATH"
}

# Export functions so they can be used by other scripts
export -f print_info print_success print_warning print_error print_step print_header
export -f command_exists directory_exists file_exists get_dotfiles_dir run_command
export -f install_essential_packages is_ubuntu is_arm64 is_x86_64 setup_ubuntu_env
