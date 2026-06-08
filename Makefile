HOME     ?= $(shell echo $$HOME)
STOW     := stow --no-folding -v --target=$(HOME)
PACKAGES := git ssh zsh claude ghostty opencode zed

.PHONY: install uninstall

install:
	mkdir -p $(HOME)/.ssh $(HOME)/.claude $(HOME)/.config/ghostty $(HOME)/.config/opencode $(HOME)/.config/zed
	$(STOW) $(PACKAGES)

uninstall:
	stow -D --no-folding -v --target=$(HOME) $(PACKAGES)
