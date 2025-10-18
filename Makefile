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
	@echo "  homebrew    - Install Homebrew"
	@echo "  brewfile    - Install packages from Brewfile"
	@echo "  oh-my-zsh   - Install Oh My Zsh and plugins"
	@echo "  stow        - Deploy all dotfiles"
	@echo "  stow-git    - Deploy Git config only"
	@echo "  stow-zsh    - Deploy Zsh config only"
	@echo "  stow-nvm    - Deploy NVM config only"
	@echo "  stow-ssh    - Deploy SSH config only"
	@echo "  stow-nvim   - Deploy Neovim config only"
	@echo "  cleanup     - Clean up duplicate configurations"
	@echo "  install     - Run full installation"
	@echo "  deploy      - Deploy all dotfiles"
	@echo "  setup       - Complete setup (install + deploy)"

# Installation
.PHONY: homebrew brewfile oh-my-zsh
homebrew:
	@bash $(SCRIPTS_DIR)/01-homebrew.sh

brewfile:
	@bash $(SCRIPTS_DIR)/02-brewfile.sh

oh-my-zsh:
	@bash $(SCRIPTS_DIR)/03-oh-my-zsh.sh

# Deployment
.PHONY: stow stow-git stow-zsh stow-nvm stow-ssh stow-nvim
stow:
	@bash $(SCRIPTS_DIR)/04-stow.sh

stow-git:
	@bash $(SCRIPTS_DIR)/04-stow.sh git

stow-zsh:
	@bash $(SCRIPTS_DIR)/04-stow.sh zsh

stow-nvm:
	@bash $(SCRIPTS_DIR)/04-stow.sh nvm

stow-ssh:
	@bash $(SCRIPTS_DIR)/04-stow.sh ssh

stow-nvim:
	@bash $(SCRIPTS_DIR)/04-stow.sh nvim

# Cleanup
.PHONY: cleanup
cleanup:
	@bash $(SCRIPTS_DIR)/cleanup-duplicates.sh

# Full setup
.PHONY: install deploy setup
install: homebrew brewfile oh-my-zsh

deploy: stow

setup: install deploy