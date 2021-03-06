#
#

MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
ifeq ($(word 1,$(subst ., ,$(MAKE_VERSION))),4)
.SHELLFLAGS := -eu -o pipefail -c
endif
.DEFAULT_GOAL := help
.ONESHELL:

include Makefile.$(shell uname -s)

UNAME := $(shell uname | tr '[:upper:]' '[:lower:]')
PWD ?= $(shell pwd)

.PHONY: default
default: brew vim essentials

.PHONY: essentials
essentials: $(HTOP) $(WATCH) less $(GREP) $(SPONGE)

.PHONY: dev
dev: vim git ~/bin/semver

.PHONY: go
go: $(GO) ~/go/bin/gojson 

.PHONY: aws
aws: bash-my-aws ~/.brew/bin/aws ~/brew/bin/kubectx

~/.brew/bin/aws:
	pip3 install aws --user

~/.brew/bin/diff:
	brew install diffutils

.PHONY: vim
vim: $(VIM) ~/.vim $(PYTHON3)

.PHONY: less
less: $(SRCHILITE)

.PHONY: git
git: ~/.gitignore_global ~/.gitconfig ~/.gitconfig_github

.PHONY: ln
ln: dots

.PHONY: dots
dots: ~/.gitignore_global ~/.gitconfig  ~/.vimrc ~/.zshrc ~/.dotfilesrc  ~/.irbrc ~/.pythonrc.py ~/.tmux.conf

~/.brew/bin/src-hilite-lesspipe.sh:
	$(BREW) install source-highlight

~/.vim: ~/.vimrc $(SHELLCHECK) $(PYCODESTYLE) $(AG) ctags $(PYLINT) $(VIM)
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall
	# this requires plugins to be installed since it creates a subfolder in there
	make ~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim
	make ~/.vim/bundle/ale/ale_linters/terraform/checkov.vim

~/bin/checkov2vim: ~/bin
	curl -sL https://github.com/mhristof/checkov2vim/releases/latest/download/checkov2vim.$(UNAME) > $@
	chmod +x $@

~/.vim/bundle/ale/ale_linters/terraform/checkov.vim: ~/bin/checkov2vim
	~/bin/checkov2vim generate --dest $@

~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim: $(CURL)
	mkdir -p ~/.vim/bundle/ale/ale_linters/groovy/
	cd ~/.vim/bundle/ale/ale_linters/groovy/
	curl -sLO https://raw.githubusercontent.com/mhristof/ale-jenkinsfile/master/ale_jenkinsfile.vim

.PHONY: ctags
ctags: $(CTAGS)
~/.brew/bin/ctags: ~/.ctags.d
	brew install --HEAD universal-ctags/universal-ctags/universal-ctags

~/.brew/opt/curl/bin/curl:
	$(BREW) install curl


~/.zshrc: ~/.zsh.autoload
	ln -sf $(PWD)/$(shell basename $@) $@

~/.oh-my-zsh:
	git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

.PHONY: zsh
zsh: $(ZSH) ~/.zshrc ~/.dotfilesrc ~/.oh-my-zsh

.PHONY: brew
brew: ~/.brew

.PHONY: fzf
fzf: ~/.brew/bin/fzf ~/.fzf.zsh

~/.fzf.zsh:
	$(shell brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

~/.brew/bin/autojump:
	$(BREW) install autojump

python3: $(PYTHON3) ~/.irbrc ~/.pythonrc.py
	pip3 install -r requirements.yml

~/.brew/opt/findutils/libexec/gnubin/xargs:
	$(BREW) install findutils

~/.brew/opt/coreutils:
	$(BREW) install coreutils

aws-azure-login: ~/.brew/bin/node
	npm install -g aws-azure-login@1.13.0

.PHONY: iterm
iterm: ~/.iterm2_shell_integration.zsh /Applications/iTerm.app ~/bin/germ

~/.iterm2_shell_integration.zsh: ~/.brew/opt/curl/bin/curl
	curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
	patch -p1 -R < data/iterm-zsh.patch

/Applications/iTerm.app: ~/.brew/bin/python3
	brew cask install iterm2

~/bin/germ: ~/.zsh.site-functions
	wget --quiet https://github.com/mhristof/germ/releases/download/v1.8.3/germ.$(UNAME) -O ~/bin/germ
	chmod +x ~/bin/germ
	~/bin/germ autocomplete > ~/.zsh.site-functions/_germ

dock: ~/.brew/opt/findutils/libexec/gnubin/xargs ~/.brew/bin/dockutil
	dockutil --list | sed 's/file:.*//g' | xargs --no-run-if-empty -n1 -d'\n' dockutil --remove

/Applications/Alfred 4.app:
	brew cask install alfred
	open /Applications/Alfred\ 4.app/Contents/MacOS/Alfred

~/.brew/opt/make/libexec/gnubin/make:
	$(BREW) install make

.PHONY: docker
docker: /Applications/Docker.app/Contents/MacOS/Docker

/Applications/Docker.app/Contents/MacOS/Docker:
	brew cask install docker

pbpaste: /tmp/alfred-pbpaste.alfredworkflow
	open /tmp/alfred-pbpaste.alfredworkflow

alfred: ~/.brew/bin/wget /tmp/alfred-tf-snippets.alfredworkflow pbpaste $(GREP)
	open /tmp/alfred-tf-snippets.alfredworkflow

/tmp/alfred-pbpaste.alfredworkflow:
	wget --quiet https://github.com/mhristof/alfred-pbpaste/releases/download/0.6.3/alfred-pbpaste.alfredworkflow -O alfred-pbpaste.alfredworkflow

/tmp/alfred-tf-snippets.alfredworkflow: ~/.brew/bin/jq
	wget https://github.com/mhristof/alfred-tf-snippets/releases/download/0.7.0/alfred-tf-snippets.alfredworkflow -O /tmp/alfred-tf-snippets.alfredworkflow

~/go/bin/gojson:
	go get github.com/ChimeraCoder/gojson/gojson

terraform-docs:
	curl --silent --location --output $@ https://github.com/terraform-docs/terraform-docs/releases/download/v0.11.0/terraform-docs-v0.11.0-$(shell tr '[:upper:]' '[:lower:]')-amd64
	chmod +x terraform-docs

slack:
	brew cask install slack

.PHONY: shortcut
shortcut:
	./setup-mac-shortcuts.sh

~/bin:
	ln -sf $(PWD) ~/bin

pterm:
	pip3 install -U pterm

bash-my-aws: ~/.bash-my-aws

~/.bash-my-aws:
	git clone https://github.com/bash-my-aws/bash-my-aws.git ~/.bash-my-aws

~/.brew:
	git clone https://github.com/Homebrew/brew.git ~/.brew
	$(BREW) tap homebrew/core
	$(BREW) --version

~/bin/semver: ~/bin ~/.zsh.site-functions
	wget --quiet https://github.com/mhristof/semver/releases/download/v0.3.2/semver.$(UNAME) -O ~/bin/semver
	chmod +x ~/bin/semver
	~/bin/semver autocomplete > ~/.zsh.site-functions/_semver

~/.zsh.site-functions:
	mkdir -p $@

~/.brew/bin/%: ~/.brew
	$(BREW) install $*

~/.%:
	ln -sf $(PWD)/$(shell basename $@) $@

build: dockerfiles/linux.apt
	docker build -f dockerfiles/linux.apt -t dotfiles-apt .

linux-test:
	docker run dotfiles-apt make vim

hub: build
	docker build -f dockerfiles/hub -t mhristof/dotfiles-apt .

push:
	docker push mhristof/dotfiles-apt

run: build
	docker run -it dotfiles-apt bash

.PHONY: build.amazon
build.amazon: dockerfiles/linux.amazon
	docker build -f dockerfiles/linux.amazon -t dotfiles-amazon .

amazon: build.amazon
	docker run --rm -it dotfiles-amazon bash

amazon-test: build.amazon
	docker run --rm dotfiles-amazon make zsh dev

# vim:ft=make
#

