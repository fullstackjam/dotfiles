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
	@echo "  nvm         - Install nvm (Node Version Manager)"
	@echo "  oh-my-zsh   - Install Oh My ZSH with plugins"
	@echo "  stow        - Deploy all dotfiles"
	@echo "  stow-git    - Deploy Git config only"
	@echo "  stow-nvm    - Deploy NVM config only"
	@echo "  stow-ssh    - Deploy SSH config only"
	@echo "  stow-nvim   - Deploy Neovim config only"
	@echo "  stow-zsh    - Deploy ZSH config only"
	@echo "  install     - Run full installation"
	@echo "  deploy      - Deploy all dotfiles"
	@echo "  setup       - Complete setup (install + deploy)"

# Installation
.PHONY: homebrew brewfile nvm oh-my-zsh
homebrew:
	@bash $(SCRIPTS_DIR)/01-homebrew.sh

brewfile: homebrew
	@bash $(SCRIPTS_DIR)/02-brewfile.sh

nvm:
	@bash $(SCRIPTS_DIR)/install-nvm.sh

oh-my-zsh:
	@bash $(SCRIPTS_DIR)/install-oh-my-zsh.sh


# Deployment
.PHONY: stow stow-git stow-nvm stow-ssh stow-nvim stow-zsh
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

stow-zsh:
	@bash $(SCRIPTS_DIR)/03-stow.sh zsh



# Full setup
.PHONY: install deploy setup
install: homebrew brewfile nvm oh-my-zsh

deploy: stow

setup: install deploy