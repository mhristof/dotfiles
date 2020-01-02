#
#

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

help:  ## Show this help.
	@fgrep -h "##" Makefile* | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | column -t -s':' | sort -u

UNAME := $(shell uname)
include dotfiles/Makefile.$(UNAME)
include dotfiles/progs/*.mk

.docker-build: dotfiles/Dockerfile
	docker build -t dotfiles -f dotfiles/Dockerfile .
	touch .docker-build

bash: .docker-build
	docker run -it -v $$PWD:/work -w /work dotfiles bash

git: $(GIT_BIN) ~/.gitignore
.PHONY: git

~/.%:
	@find ~/.$* -type l -xtype d &> /dev/null || ln -s $(PWD)/dotfiles/files/$* ~/.$*

pip: $(PIP_BIN) ~/.irbrc  ~/.pythonrc.py
	pip3 install --user sh readline  pycodestyle
.PHONY: pip

clean:
	-vagrant destroy -f

all:
	@echo "Makefile needs your attention"

# vim:ft=make
#
