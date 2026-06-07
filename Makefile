HOME     ?= $(shell echo $$HOME)
STOW     := stow --no-folding -v --target=$(HOME)
PACKAGES := git ssh zsh claude ghostty opencode

.PHONY: install uninstall

install:
	mkdir -p $(HOME)/.ssh $(HOME)/.claude $(HOME)/.config/ghostty $(HOME)/.config/opencode
	$(STOW) $(PACKAGES)

uninstall:
	stow -D --no-folding -v --target=$(HOME) $(PACKAGES)
