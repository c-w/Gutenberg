MODULE=gutenberg
AUTHOR=Clemens Wolff
VERSION=0.1

SRC_DIR=$(MODULE)
DOC_DIR=docs
DIST_DIR=dist
VENV_DIR=virtualenv

VENV_ACTIVATE=$(VENV_DIR)/bin/activate

.PHONY: test dist clean docs lint


virtualenv: $(VENV_ACTIVATE)
$(VENV_ACTIVATE): requirements.txt
	test -d "$(VENV_DIR)" || virtualenv "$(VENV_DIR)"
	. "$(VENV_ACTIVATE)"; pip install -U -r requirements.txt
	touch "$(VENV_ACTIVATE)"

test: virtualenv
	. "$(VENV_ACTIVATE)"; \
	nosetests --verbose --with-doctest

dist:
	. "$(VENV_ACTIVATE)"; \
	python setup.py sdist --dist-dir="$(DIST_DIR)"

clean:
	find "$(SRC_DIR)" -name *.pyc -type f -delete
	rm -f MANIFEST
	rm -rf "$(DIST_DIR)"

setup_docs: virtualenv
	. "$(VENV_ACTIVATE)"; \
	sphinx-apidoc \
		--output-dir="$(DOC_DIR)" \
		--full \
		--separate \
		--doc-author="$(AUTHOR)" \
		--doc-version="$(VERSION)" \
		"$(SRC_DIR)"

docs: setup_docs
	. "$(VENV_ACTIVATE)"; \
	cd "$(DOC_DIR)" && make html && cd -

lint: virtualenv
	. "$(VENV_ACTIVATE)"; \
	pylint "$(SRC_DIR)" \
		--output-format=colorized \
		--reports=no \
		--rcfile=.pylintrc \
	|| true
