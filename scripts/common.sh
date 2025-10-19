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

# Function to install Homebrew if not installed
install_homebrew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Setup Homebrew environment after installation
        setup_homebrew_env
        
        print_success "Homebrew installed successfully!"
        return 0
    else
        print_success "Homebrew is already installed"
        # Still setup environment to ensure it's properly configured
        setup_homebrew_env
        return 0
    fi
}

# Function to check if running on macOS
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

# Function to check if running on Apple Silicon
is_apple_silicon() {
    [[ $(uname -m) == "arm64" ]]
}

# Function to check if running on Intel Mac
is_intel_mac() {
    [[ $(uname -m) == "x86_64" ]]
}

# Function to setup Homebrew environment
setup_homebrew_env() {
    local brew_path=""
    local brew_shellenv=""
    
    if is_apple_silicon; then
        brew_path="/opt/homebrew/bin/brew"
        brew_shellenv='eval "$(/opt/homebrew/bin/brew shellenv)"'
        print_info "Setting up Homebrew environment for Apple Silicon..."
    elif is_intel_mac; then
        brew_path="/usr/local/bin/brew"
        brew_shellenv='eval "$(/usr/local/bin/brew shellenv)"'
        print_info "Setting up Homebrew environment for Intel Mac..."
    else
        print_warning "Unsupported architecture for Homebrew setup"
        return 1
    fi
    
    # Check if Homebrew shellenv is already in .zprofile
    local zprofile_path="$HOME/.zprofile"
    if [ ! -f "$zprofile_path" ]; then
        touch "$zprofile_path"
        print_info "Created $zprofile_path"
        echo "$brew_shellenv" >> "$zprofile_path"
        print_info "Added Homebrew to $zprofile_path"
    elif ! grep -q "brew shellenv" "$zprofile_path" 2>/dev/null; then
        echo "$brew_shellenv" >> "$zprofile_path"
        print_info "Added Homebrew to $zprofile_path"
    else
        print_info "Homebrew already configured in $zprofile_path"
    fi
    
    # Apply Homebrew environment to current session
    eval "$brew_shellenv"
}

# Export functions so they can be used by other scripts
export -f print_info print_success print_warning print_error print_step print_header
export -f command_exists directory_exists file_exists get_dotfiles_dir run_command
export -f install_homebrew is_macos is_apple_silicon is_intel_mac setup_homebrew_env
