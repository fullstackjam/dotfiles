PYTHON ?= python3
DEPLOY = $(PYTHON) scripts/deploy.py --target "$(HOME)"

.PHONY: check install uninstall test

check:
	$(DEPLOY) check

install:
	$(DEPLOY) install

uninstall:
	$(DEPLOY) uninstall

test:
	$(PYTHON) -B -m unittest discover -s tests -v
