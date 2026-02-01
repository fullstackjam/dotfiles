#!/bin/bash
# 03-stow.sh - Deploy dotfiles using GNU Stow

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Deploying dotfiles with GNU Stow"

# Get dotfiles directory
DOTFILES_DIR=$(get_dotfiles_dir)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

backup_existing_files() {
    local package="$1"
    local package_dir="$DOTFILES_DIR/$package"
    local backed_up=false
    
    while IFS= read -r -d '' file; do
        local relative_path="${file#$package_dir/}"
        local target_file="$HOME/$relative_path"
        
        if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$relative_path")"
            cp "$target_file" "$BACKUP_DIR/$relative_path"
            backed_up=true
        fi
    done < <(find "$package_dir" -type f -print0)
    
    if [ "$backed_up" = true ]; then
        print_info "Backed up existing files to $BACKUP_DIR"
    fi
}

configure_git_user() {
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    
    if [ "$current_name" = "fullstackjam" ] || [ -z "$current_name" ]; then
        print_info "Git user not configured. Please enter your details:"
        
        read -p "Your name: " git_name
        read -p "Your email: " git_email
        
        if [ -n "$git_name" ] && [ -n "$git_email" ]; then
            git config --global user.name "$git_name"
            git config --global user.email "$git_email"
            print_success "Git user configured: $git_name <$git_email>"
        else
            print_warning "Skipped. Update ~/.gitconfig manually."
        fi
    fi
}

# Check if stow is installed
if ! command_exists stow; then
    print_error "GNU Stow is not installed! Please install it first:"
    print_info "brew install stow"
    exit 1
fi

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Define packages to deploy
PACKAGES=("git" "ssh" "zsh")

# Handle command line arguments
if [ -n "$1" ]; then
    # Deploy specific package
    package="$1"
    if directory_exists "$package"; then
        backup_existing_files "$package"
        print_info "Deploying $package configuration..."
        if stow --adopt --target="$HOME" "$package"; then
            print_success "$package configuration deployed successfully!"
        else
            print_error "Failed to deploy $package configuration!"
            exit 1
        fi
    else
        print_warning "Package directory '$package' not found, skipping..."
    fi
else
    # Deploy all packages
    for package in "${PACKAGES[@]}"; do
        if directory_exists "$package"; then
            backup_existing_files "$package"
            print_info "Deploying $package configuration..."
            if stow --adopt --target="$HOME" "$package"; then
                print_success "$package configuration deployed successfully!"
            else
                print_error "Failed to deploy $package configuration!"
                exit 1
            fi
        else
            print_warning "Package directory '$package' not found, skipping..."
        fi
    done
    print_success "All dotfiles deployed successfully!"
    
    configure_git_user
fi
