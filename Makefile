# Dotfiles Makefile

# Variables
SCRIPTS_DIR := scripts

# Default target
.PHONY: all
all: help

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  setup         - Complete setup (install + deploy + configure)"
	@echo "  install       - Run full installation (brew + npm)"
	@echo "  deploy        - Deploy all dotfiles"
	@echo "  uninstall     - Remove deployed dotfiles (restores from backup if available)"
	@echo "  backup        - Backup current dotfiles to ~/.dotfiles-backup"
	@echo "  dry-run       - Show what stow would do without making changes"
	@echo ""
	@echo "  homebrew      - Install Homebrew"
	@echo "  brewfile      - Install packages from Brewfile"
	@echo "  npm           - Install npm packages"
	@echo "  oh-my-zsh     - Install Oh My ZSH with plugins"
	@echo "  configure     - Configure macOS preferences"
	@echo "  stow          - Deploy all dotfiles"
	@echo "  stow-git      - Deploy Git config only"
	@echo "  stow-ssh      - Deploy SSH config only"
	@echo "  stow-zsh      - Deploy ZSH config only"

# Installation
.PHONY: homebrew brewfile npm oh-my-zsh configure
homebrew:
	@bash $(SCRIPTS_DIR)/01-homebrew.sh

brewfile: homebrew
	@bash $(SCRIPTS_DIR)/02-brewfile.sh

npm: brewfile
	@bash $(SCRIPTS_DIR)/05-npm-packages.sh

oh-my-zsh:
	@bash $(SCRIPTS_DIR)/install-oh-my-zsh.sh

configure:
	@bash $(SCRIPTS_DIR)/04-configure-macos.sh


# Deployment
.PHONY: stow stow-git stow-ssh stow-zsh
stow: oh-my-zsh
	@bash $(SCRIPTS_DIR)/03-stow.sh

stow-git:
	@bash $(SCRIPTS_DIR)/03-stow.sh git


stow-ssh:
	@bash $(SCRIPTS_DIR)/03-stow.sh ssh


stow-zsh:
	@bash $(SCRIPTS_DIR)/03-stow.sh zsh



# Full setup
.PHONY: install deploy setup
install: homebrew brewfile npm

deploy: stow

setup: install deploy configure

# Maintenance
.PHONY: uninstall backup dry-run
uninstall:
	@echo "Removing stow symlinks..."
	@cd $(CURDIR) && stow -D -t "$(HOME)" git ssh zsh 2>/dev/null || true
	@echo "Done. Check ~/.dotfiles-backup for previous configs."

backup:
	@BACKUP_DIR="$(HOME)/.dotfiles-backup/$$(date +%Y%m%d-%H%M%S)" && \
	mkdir -p "$$BACKUP_DIR" && \
	for f in .gitconfig .ssh/config .zshrc; do \
		[ -f "$(HOME)/$$f" ] && cp "$(HOME)/$$f" "$$BACKUP_DIR/$$f" 2>/dev/null || true; \
	done && \
	echo "Backed up to $$BACKUP_DIR"

dry-run:
	@echo "=== Dry run: showing what stow would do ==="
	@cd $(CURDIR) && stow -n -v --target="$(HOME)" git ssh zsh 2>&1 || true
