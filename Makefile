# Dotfiles Makefile

.DEFAULT_GOAL := setup

.PHONY: setup homebrew brewfile link-ssh macos help

setup: homebrew brewfile link-ssh macos

homebrew:
	@bash scripts/01-homebrew.sh

brewfile: homebrew
	@bash scripts/02-brewfile.sh

link-ssh:
	@bash scripts/03-link-ssh.sh

macos:
	@bash scripts/04-configure-macos.sh

help:
	@echo "Targets:"
	@echo "  setup      - run homebrew, brewfile, link-ssh, macos"
	@echo "  homebrew   - install Homebrew"
	@echo "  brewfile   - install Brewfile packages"
	@echo "  link-ssh   - symlink SSH config"
	@echo "  macos      - apply Dock, Trackpad, and login item settings"