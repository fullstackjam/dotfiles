# Dotfiles - Pure configuration files managed with GNU Stow
# Software installation: https://openboot.dev/fullstackjam/dotfiles/install

.PHONY: all help deploy uninstall backup dry-run

all: help

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "  make deploy    - Deploy all dotfiles via stow"
	@echo "  make uninstall - Remove deployed dotfiles"
	@echo "  make backup    - Backup current dotfiles"
	@echo "  make dry-run   - Preview changes without applying"
	@echo ""
	@echo "Software installation (separate from dotfiles):"
	@echo "  curl -fsSL openboot.dev/fullstackjam/dotfiles/install | bash"

deploy:
	@bash scripts/stow.sh

uninstall:
	@echo "Removing stow symlinks..."
	@stow -D -t "$(HOME)" git ssh zsh npm 2>/dev/null || true
	@echo "Done."

backup:
	@BACKUP_DIR="$(HOME)/.dotfiles-backup/$$(date +%Y%m%d-%H%M%S)" && \
	mkdir -p "$$BACKUP_DIR" && \
	for f in .gitconfig .ssh/config .zshrc .npmrc; do \
		[ -f "$(HOME)/$$f" ] && cp "$(HOME)/$$f" "$$BACKUP_DIR/" 2>/dev/null || true; \
	done && \
	echo "Backed up to $$BACKUP_DIR"

dry-run:
	@echo "=== Dry run: showing what stow would do ==="
	@stow -n -v --target="$(HOME)" git ssh zsh npm 2>&1 || true
