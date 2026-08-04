HOME            ?= $(shell echo $$HOME)
STOW            := stow -v --target=$(HOME)
PACKAGES        := git ssh zsh claude codex ghostty zed
FOLDED_PACKAGES := agents

.PHONY: install uninstall

install:
	mkdir -p $(HOME)/.ssh $(HOME)/.claude $(HOME)/.codex $(HOME)/.agents/skills $(HOME)/.config/ghostty $(HOME)/.config/zed
	$(STOW) $(FOLDED_PACKAGES)
	$(STOW) --no-folding $(PACKAGES)

uninstall:
	$(STOW) -D --no-folding $(PACKAGES)
	$(STOW) -D $(FOLDED_PACKAGES)
