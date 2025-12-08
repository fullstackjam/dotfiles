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
	@echo "  homebrew      - Install Homebrew"
	@echo "  brewfile      - Install packages from Brewfile"
	@echo "  oh-my-zsh     - Install Oh My ZSH with plugins"
	@echo "  configure     - Configure macOS preferences (Dock, Trackpad, Login Items)"
	@echo "  stow          - Deploy all dotfiles"
	@echo "  stow-git      - Deploy Git config only"
	@echo "  stow-nvm      - Deploy NVM config only"
	@echo "  stow-ssh      - Deploy SSH config only"
	@echo "  stow-zsh      - Deploy ZSH config only"
	@echo "  install       - Run full installation"
	@echo "  deploy        - Deploy all dotfiles"
	@echo "  setup         - Complete setup (install + deploy + configure)"

# Installation
.PHONY: homebrew brewfile nvm oh-my-zsh configure
homebrew:
	@bash $(SCRIPTS_DIR)/01-homebrew.sh

brewfile: homebrew
	@bash $(SCRIPTS_DIR)/02-brewfile.sh

nvm:
	@bash $(SCRIPTS_DIR)/install-nvm.sh

oh-my-zsh:
	@bash $(SCRIPTS_DIR)/install-oh-my-zsh.sh

configure:
	@bash $(SCRIPTS_DIR)/04-configure-macos.sh


# Deployment
.PHONY: stow stow-git stow-nvm stow-ssh stow-nvim stow-zsh
stow:
	@bash $(SCRIPTS_DIR)/03-stow.sh

stow-git:
	@bash $(SCRIPTS_DIR)/03-stow.sh git


stow-ssh:
	@bash $(SCRIPTS_DIR)/03-stow.sh ssh


stow-zsh:
	@bash $(SCRIPTS_DIR)/03-stow.sh zsh



# Full setup
.PHONY: install deploy setup
install: homebrew brewfile

deploy: stow nvm oh-my-zsh

setup: install deploy configure
