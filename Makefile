#
#

MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
ifeq ($(word 1,$(subst ., ,$(MAKE_VERSION))),4)
.SHELLFLAGS := -eu -o pipefail -c
endif
.DEFAULT_GOAL := help
.ONESHELL:

BREW_BIN := /usr/local/bin
include Makefile.$(shell uname -s)

UNAME := $(shell uname | tr '[:upper:]' '[:lower:]')
PWD ?= $(shell pwd)

.PHONY: default
default: brew vim essentials

.PHONY: essentials
essentials: $(HTOP) $(WATCH) less $(GREP) $(SPONGE)

.PHONY: dev
dev: essentials dots vim git ~/bin/semver $(LS) $(WATCH) $(JQ) $(AUTOJUMP)

.PHONY: go
go: $(GO) ~/go/bin/gojson 

.PHONY: aws
aws: bash-my-aws $(BREW_BIN)/aws $(BREW_BIN)/kubectx

$(BREW_BIN)/aws:
	pip3 install aws --user

$(BREW_BIN)/diff:
	brew install diffutils

.PHONY: vim
vim: $(VIM) ~/.vim $(PYTHON3)

.PHONY: less
less: $(SRCHILITE)

.PHONY: git
git: ~/.gitignore_global ~/.gitconfig ~/.gitconfig_github gh

.PHONY: ln
ln: dots

.PHONY: dots
dots: ~/.gitignore_global ~/.gitconfig  ~/.vimrc ~/.zshrc ~/.dotfilesrc  ~/.irbrc ~/.pythonrc.py ~/.tmux.conf ~/.p10k.zsh

~/.p10k.zsh:
	brew install romkatv/powerlevel10k/powerlevel10k
	ln -sf $(PWD)/$(shell basename $@) $@

$(BREW_BIN)/src-hilite-lesspipe.sh:
	$(BREW) install source-highlight

~/.vim: ~/.vimrc $(SHELLCHECK) $(PYCODESTYLE) $(AG) ctags $(PYLINT) $(VIM) tflint golangci-lint

~/.vim/bundle/Vundle.vim:
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

~/.vim: ~/.vim/bundle/Vundle.vim ~/.vimrc $(SHELLCHECK) $(PYCODESTYLE) $(AG) ctags $(PYLINT) $(VIM)
	vim +PluginInstall +qall
	# this requires plugins to be installed since it creates a subfolder in there
	make ~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim
	make ~/.vim/bundle/ale/ale_linters/terraform/checkov.vim

.PHONY: tflint
tflint: ~/.tflint.d/plugins/tflint-ruleset-aws

~/.tflint.d/plugins/tflint-ruleset-aws: $(TFLINT) ~/.tflint.hcl
	curl --location --silent https://github.com/terraform-linters/tflint-ruleset-aws/releases/download/v0.3.0/tflint-ruleset-aws_$(UNAME)_amd64.zip > /tmp/tflint-ruleset-aws.zip
	unzip /tmp/tflint-ruleset-aws.zip
	mkdir -p $(shell dirname $@)
	mv tflint-ruleset-aws $@

.PHONY: checkov
checkov: $(CHECKOV)

~/bin/checkov2vim: ~/bin checkov
	curl -sL https://github.com/mhristof/checkov2vim/releases/latest/download/checkov2vim.$(UNAME) > $@
	chmod +x $@

~/.vim/bundle/ale/ale_linters/terraform/checkov.vim: ~/bin/checkov2vim
	~/bin/checkov2vim generate --dest $@

~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim: $(CURL)
	mkdir -p ~/.vim/bundle/ale/ale_linters/groovy/
	cd ~/.vim/bundle/ale/ale_linters/groovy/
	curl -sLO https://raw.githubusercontent.com/mhristof/ale-jenkinsfile/master/ale_jenkinsfile.vim

.PHONY: ctags
ctags: $(CTAGS) ~/.ctags.d

$(BREW_BIN)/curl/bin/curl:
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
fzf: $(BREW_BIN)/fzf ~/.fzf.zsh
	$(brew --prefix)/opt/fzf/install

~/.fzf.zsh:
	$(shell brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

$(BREW_BIN)/autojump:
	$(BREW) install autojump

python3: $(PYTHON3) ~/.irbrc ~/.pythonrc.py
	pip3 install -r requirements.yml

$(BREW_BIN)/findutils/libexec/gnubin/xargs:
	$(BREW) install findutils

$(BREW_BIN)/coreutils:
	$(BREW) install coreutils

aws-azure-login: $(BREW_BIN)/node
	npm install -g aws-azure-login@1.13.0

.PHONY: iterm
iterm: ~/.iterm2_shell_integration.zsh /Applications/iTerm.app germ

~/.iterm2_shell_integration.zsh: $(BREW_BIN)/curl/bin/curl
	curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
	patch -p1 -R < data/iterm-zsh.patch

/Applications/iTerm.app: $(BREW_BIN)/python3
	brew cask install iterm2

germ: ~/bin/germ

~/bin/germ: ~/.zsh.site-functions
	wget --quiet https://github.com/mhristof/germ/releases/download/v1.8.3/germ.$(UNAME) -O ~/bin/germ
	chmod +x ~/bin/germ
	~/bin/germ autocomplete zsh > ~/.zsh.site-functions/_germ

~/bin/githubactions-docs:
	wget --quiet https://github.com/mhristof/githubactions-docs/releases/download/v0.2.0/$(shell basename $@).$(UNAME) -O $@
	chmod +x $@
	$@ autocomplete zsh > ~/.zsh.site-functions/_$(shell basename $@)

dock: $(BREW_BIN)/findutils/libexec/gnubin/xargs $(BREW_BIN)/dockutil
	dockutil --list | sed 's/file:.*//g' | xargs --no-run-if-empty -n1 -d'\n' dockutil --remove

/Applications/Alfred 4.app:
	brew cask install alfred
	open /Applications/Alfred\ 4.app/Contents/MacOS/Alfred

$(BREW_BIN)/make/libexec/gnubin/make:
	$(BREW) install make

.PHONY: docker
docker: /Applications/Docker.app/Contents/MacOS/Docker

/Applications/Docker.app/Contents/MacOS/Docker:
	brew cask install docker

pbpaste: /tmp/alfred-pbpaste.alfredworkflow
	open /tmp/alfred-pbpaste.alfredworkflow

alfred: $(BREW_BIN)/wget /tmp/alfred-tf-snippets.alfredworkflow pbpaste $(GREP)
	open /tmp/alfred-tf-snippets.alfredworkflow

/tmp/alfred-pbpaste.alfredworkflow:
	wget --quiet https://github.com/mhristof/alfred-pbpaste/releases/download/0.6.3/alfred-pbpaste.alfredworkflow -O alfred-pbpaste.alfredworkflow

/tmp/alfred-tf-snippets.alfredworkflow: $(BREW_BIN)/jq
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

~/bin/semver: $(WGET) ~/bin ~/.zsh.site-functions
	wget --quiet https://github.com/mhristof/semver/releases/download/v0.3.2/semver.$(UNAME) -O ~/bin/semver
	chmod +x ~/bin/semver
	~/bin/semver autocomplete zsh > ~/.zsh.site-functions/_semver

.PHONY: gh
gh: ~/.local/bin/gh
~/.local/bin/gh: ~/.local/bin
	wget --quiet https://github.com/cli/cli/releases/download/v1.7.0/gh_1.7.0_$(GH_OS)_amd64.tar.gz -O /tmp/gh.tar.gz
	tar xf /tmp/gh.tar.gz -C /tmp/
	mv /tmp/gh_*/bin/gh $@

.PHONY: golangci-lint
golangci-lint: ~/.local/bin/golangci-lint
~/.local/bin/golangci-lint: ~/.local/bin
	curl --location --silent https://github.com/golangci/golangci-lint/releases/download/v1.39.0/golangci-lint-1.39.0-$(UNAME)-amd64.tar.gz > /tmp/golangci-lint.tar.gz
	tar xvf /tmp/golangci-lint.tar.gz -C /tmp/
	mv /tmp/golangci-lint-*-$(UNAME)-amd64/golangci-lint $@

~/.zsh.site-functions:
	mkdir -p $@

~/.local/bin:
	mkdir -p $@

$(BREW_BIN)/%:
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

.PHONY: all
all: dev

.PHONY: test
test:
	grep 'g:ale_linters' ~/.vimrc | cut -d= -f2  | grep -oP "[\w-]*" | xargs -I{} bash -c 'command -v {} || (echo Could not find {}; exit 1)'

.PHONY: clean
clean:

# vim:ft=make
