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
	@echo "  stow        - Deploy all dotfiles"
	@echo "  stow-git    - Deploy Git config only"
	@echo "  stow-nvm    - Deploy NVM config only"
	@echo "  stow-ssh    - Deploy SSH config only"
	@echo "  stow-nvim   - Deploy Neovim config only"
	@echo "  install     - Run full installation"
	@echo "  deploy      - Deploy all dotfiles"
	@echo "  setup       - Complete setup (install + deploy)"

# Installation
.PHONY: homebrew brewfile
homebrew:
	@bash $(SCRIPTS_DIR)/01-homebrew.sh

brewfile: homebrew
	@bash $(SCRIPTS_DIR)/02-brewfile.sh


# Deployment
.PHONY: stow stow-git stow-zsh stow-nvm stow-ssh stow-nvim
stow:
	@bash $(SCRIPTS_DIR)/03-stow.sh

stow-git:
	@bash $(SCRIPTS_DIR)/03-stow.sh git


stow-nvm:
	@bash $(SCRIPTS_DIR)/03-stow.sh nvm

stow-ssh:
	@bash $(SCRIPTS_DIR)/03-stow.sh ssh

stow-nvim:
	@bash $(SCRIPTS_DIR)/03-stow.sh nvim



# Full setup
.PHONY: install deploy setup
install: homebrew brewfile

deploy: stow

setup: install deploy