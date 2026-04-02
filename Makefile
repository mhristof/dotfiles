#
#

MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
ifeq ($(word 1,$(subst ., ,$(MAKE_VERSION))),4)
.SHELLFLAGS := -eu -o pipefail -c
endif
.DEFAULT_GOAL := default
.ONESHELL:

BREW_BIN := $(shell brew --prefix 2>/dev/null)/bin
GH_OS := macOS
UNAME := $(shell uname | tr '[:upper:]' '[:lower:]')
VENDOR := apple
BREW := $(shell which brew 2>/dev/null)

AG := $(BREW_BIN)/ag
AUTOJUMP := $(BREW_BIN)/autojump
BANDIT := $(BREW_BIN)/bandit
CTAGS := $(BREW_BIN)/ctags
CURL := $(abspath $(BREW_BIN)/../opt/curl/bin/curl)
EXA := $(BREW_BIN)/eza
GO := $(BREW_BIN)/go
GREP := $(abspath $(BREW_BIN)/../opt/grep/libexec/gnubin/grep)
HELM := $(BREW_BIN)/helm
HTOP := $(BREW_BIN)/htop
JQ := $(BREW_BIN)/jq
K9S := $(BREW_BIN)/k9s
LS := $(abspath $(BREW_BIN)/../opt/coreutils)
PYCODESTYLE := $(BREW_BIN)/pycodestyle
PYLINT := $(BREW_BIN)/pylint
PYTHON3 := $(BREW_BIN)/python3
SHELLCHECK := $(BREW_BIN)/shellcheck
SPONGE := $(BREW_BIN)/sponge
SRCHILITE := $(BREW_BIN)/src-hilite-lesspipe.sh
VIM := $(BREW_BIN)/vim
WATCH := $(BREW_BIN)/watch
WGET := $(BREW_BIN)/wget
XARGS := $(abspath $(BREW_BIN)/../opt/findutils)
YAMLLINT := $(BREW_BIN)/yamllint
ZSH := $(BREW_BIN)/zsh

DEV := essentials dots vim bat git ~/bin/semver $(LS) $(WATCH) $(JQ) $(AUTOJUMP) eza

PWD ?= $(shell pwd)
FIRST_VIM_PLUGIN := ~/.vim/bundle/$(shell basename $(shell grep Plugin .vimrc | head -2 | tail -1 | cut -d"'" -f2) .git)

.PHONY: help
help: ## Show available targets
	@grep --extended-regexp '^\S+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: default
default: install-brew dirs zsh dots vim clear-dock fzf brew ## Full setup (default)

.PHONY: clear-dock
clear-dock: ## Remove all icons from the Dock
	@./clear-dock.sh

.PHONY: dirs
dirs: ~/.local/bin ~/.zsh.site-functions ## Create required directories

.PHONY: essentials
essentials: $(HTOP) $(WATCH) less $(GREP) $(SPONGE) ## Install essential CLI tools

.PHONY: dev
dev: $(DEV) ## Install dev tools (essentials + vim + git + more)

.PHONY: go
go: $(GO) ~/go/bin/gojson ## Install Go and tools

.PHONY: aws
aws: bash-my-aws $(BREW_BIN)/aws $(BREW_BIN)/kubectx ## Install AWS CLI tools

.PHONY: k8s
k8s: $(K9S) ## Install Kubernetes tools

$(BREW_BIN)/aws:
	pip3 install aws --user

$(BREW_BIN)/diff:
	brew install diffutils

.PHONY: vim
vim: ~/.vimrc ~/.vim/bundle/Vundle.vim vim-tools vim-plugins ~/bin/gitbrowse ## Setup vim config and plugins

.PHONY: vim-tools
vim-tools: ctags
	@command -v vim &>/dev/null || brew install vim
	@command -v ag &>/dev/null || brew install the_silver_searcher

.PHONY: vim-linters
vim-linters: golangci-lint shfmt ## Install vim linters
	brew list shellcheck &>/dev/null || brew install shellcheck
	brew list pipx &>/dev/null || brew install pipx
	pipx install bandit || true
	pipx install pycodestyle || true
	pipx install pylint || true
	pipx install yamllint || true

.PHONY: vim-plugins
vim-plugins: ~/.vim/bundle/Vundle.vim
	@test -d $(FIRST_VIM_PLUGIN) || vim +PluginInstall +qall

.PHONY: less
less: $(SRCHILITE)

.PHONY: git
git: ~/.gitignore.global ~/.gitconfig ~/.gitconfig.github gh ## Setup git config

.PHONY: ssh-key
ssh-key: ## Generate a new SSH key and copy to clipboard
	@if [ -f ~/.ssh/id_ed25519 ]; then \
		echo "SSH key already exists at ~/.ssh/id_ed25519"; \
		echo "Remove it first if you want to generate a new one"; \
		exit 1; \
	fi
	ssh-keygen -t ed25519 -C "$(GIT_EMAIL)" -f ~/.ssh/id_ed25519
	chmod 600 ~/.ssh/id_ed25519
	chmod 644 ~/.ssh/id_ed25519.pub
	ssh-add ~/.ssh/id_ed25519
	@echo ""
	@echo "SSH key generated successfully!"
	@echo "Public key copied to clipboard. Add it to GitHub:"
	@echo "https://github.com/settings/ssh/new"
	@cat ~/.ssh/id_ed25519.pub | pbcopy

.PHONY: ln
ln: dots

# List of all dotfiles to install
DOTFILES := .gitignore_global .gitconfig .vimrc .zshrc .dotfilesrc .pythonrc.py .tmux.conf .p10k.zsh .agignore .bash_profile .gitconfig.github .lessfilter .pdbrc .tflint.hcl .Xresources .tfswitch.toml

.PHONY: dots
dots: $(addprefix ~/,$(DOTFILES)) ~/.config/nvim/init.vim ~/bin ## Symlink dotfiles to home

.PHONY: $(DOTFILES)
$(DOTFILES): %: ~/.%

~/.config/nvim/init.vim:
	@mkdir -p ~/.config/nvim
	@test -L $@ || ln -sf $(PWD)/.config/nvim/init.vim $@

~/.p10k.zsh:
	@command -v p10k &>/dev/null || brew install powerlevel10k
	@test -L $@ || ln -sf $(PWD)/$(shell basename $@) $@

$(SRCHILITE):
	$(BREW) install source-highlight

~/.vim/bundle/Vundle.vim:
	@test -d $@ || git clone https://github.com/VundleVim/Vundle.vim.git $@

.PHONY: ctags
ctags: $(CTAGS) ~/.ctags.d

$(BREW_BIN)/curl/bin/curl:
	$(BREW) install curl

~/.zshrc: ~/.zsh.autoload
	@test -L $@ || ln -sf $(PWD)/$(shell basename $@) $@

.PHONY: oh-my-zsh
oh-my-zsh: ## Reinstall oh-my-zsh and fzf-tab
	rm -rf ~/.oh-my-zsh
	ZSH=~/.oh-my-zsh SHELL=/opt/homebrew/bin/zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
	git clone https://github.com/Aloxaf/fzf-tab ~/.oh-my-zsh/custom/plugins/fzf-tab

~/.oh-my-zsh:
	@test -d $@/lib || ZSH=$@ SHELL=/opt/homebrew/bin/zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
	@test -d $@/custom/plugins/fzf-tab || git clone https://github.com/Aloxaf/fzf-tab $@/custom/plugins/fzf-tab

.PHONY: zsh
zsh: $(ZSH) ~/.zshrc ~/.dotfilesrc ~/.oh-my-zsh ~/.zsh.site-functions/_clone ## Setup zsh, oh-my-zsh and config

~/.zsh.site-functions/_clone: .zsh.site-functions/_clone | ~/.zsh.site-functions
	@ln -sf $(PWD)/$< $@

.PHONY: install-brew
install-brew: ## Install Homebrew if not present
	@command -v brew &>/dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.PHONY: brew
brew: install-brew brew-packages ## Install brew and all Brewfile packages

.PHONY: brew-packages
brew-packages:
	$(BREW) update
	$(BREW) bundle --file=$(PWD)/Brewfile
	$(BREW) link moreutils 2>/dev/null || true
	$(BREW) link --overwrite parallel

.PHONY: fzf
fzf: ~/.fzf.zsh

~/.fzf.zsh:
	@command -v fzf &>/dev/null || brew install fzf
	@test -f $@ || $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish

$(BREW_BIN)/autojump:
	$(BREW) install autojump

python3: $(PYTHON3) ~/.irbrc ~/.pythonrc.py
	pip3 install -r requirements.yml

aws-azure-login: $(BREW_BIN)/node
	npm install -g aws-azure-login@1.13.0

.PHONY: iterm
iterm: /Applications/iTerm.app germ ## Install iTerm2 and germ

~/.iterm2_shell_integration.zsh: $(BREW_BIN)/curl/bin/curl
	curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash

/Applications/iTerm.app: $(BREW_BIN)/python3
	brew install iterm2

germ: ~/bin/germ $(HOME)/Library/Python/3.9/lib/python/site-packages/iterm2

$(HOME)/Library/Python/3.9/lib/python/site-packages/iterm2:
	pip install --user iterm2

~/bin/germ: $(BREW_BIN)/wget ~/.zsh.site-functions ~/bin
	wget --quiet https://github.com/mhristof/germ/releases/download/v1.15.0/germ_1.15.0_$(UNAME)_amd64 -O $@
	chmod +x $@
	$@ completion zsh > ~/.zsh.site-functions/_$(shell basename $@)

~/bin/githubactions-docs:
	wget --quiet https://github.com/mhristof/githubactions-docs/releases/download/v0.5.0/$(shell basename $@).$(UNAME) -O $@
	chmod +x $@
	$@ completion zsh > ~/.zsh.site-functions/_$(shell basename $@)

dock:
	defaults write com.apple.dock static-only -bool TRUE
	killall Dock

/Applications/Alfred 4.app:
	brew install alfred
	open /Applications/Alfred\ 4.app/Contents/MacOS/Alfred

$(BREW_BIN)/make/libexec/gnubin/make:
	$(BREW) install make

.PHONY: docker
docker: ## Install Docker Desktop and Compose plugin
	@brew list --cask docker &>/dev/null || brew install --cask docker
	@brew list docker-compose &>/dev/null || brew install docker-compose

pbpaste: /tmp/alfred-pbpaste.alfredworkflow
	open /tmp/alfred-pbpaste.alfredworkflow

alfred: $(BREW_BIN)/wget pbpaste $(GREP) /tmp/alfred-qrencode.alfredworkflow

.PHONY: qrencode
qrencode: /tmp/alfred-qrencode.alfredworkflow

/tmp/alfred-qrencode.alfredworkflow:
	curl --silent --location https://github.com/mhristof/alfred-qrencode/releases/download/v0.2.3/alfred-qrencode.alfredworkflow > $@
	open $@

.PHONY: random
random: /tmp/alfred-random.alfredworkflow

/tmp/alfred-random.alfredworkflow:
	curl --silent --location https://github.com/mhristof/alfred-random/releases/download/v0.3.0/alfred-random.alfredworkflow > $@
	open $@

/tmp/alfred-pbpaste.alfredworkflow:
	wget --quiet https://github.com/mhristof/alfred-pbpaste/releases/download/0.6.3/alfred-pbpaste.alfredworkflow -O /tmp/alfred-pbpaste.alfredworkflow

~/go/bin/gojson:
	go get github.com/ChimeraCoder/gojson/gojson

.PHONY: shfmt
shfmt: ~/.local/bin/shfmt

~/.local/bin/shfmt:
	curl --silent --location --output $@ https://github.com/mvdan/sh/releases/download/v3.4.1/shfmt_v3.4.1_$(UNAME)_amd64
	chmod +x $@

.PHONY: terraform-docs
terraform-docs:  ~/.local/bin/terraform-docs

~/.local/bin/terraform-docs: | ~/.local/bin
	curl --silent --location --output $@ https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-$(shell tr '[:upper:]' '[:lower:]' <<< "$(UNAME)")-amd64
	chmod +x $@

slack:
	brew cask install slack

.PHONY: eza
eza: $(EXA)

.PHONY: helm
helm: $(HELM)

.PHONY: k9s
k9s: $(K9S)

.PHONY: bat
bat: ~/.local/bin/bat

~/.local/bin/bat:
	curl --silent --location --output /tmp/bat.tar.gz https://github.com/sharkdp/bat/releases/download/v0.18.3/bat-v0.18.3-x86_64-$(VENDOR)-$(UNAME).tar.gz
	$(eval TEMPDIR := $(shell mktemp -d))
	tar xvf /tmp/bat.tar.gz -C $(TEMPDIR)
	mv $(TEMPDIR)/bat*/bat $@
	rm -rf $(TEMPDIR)

.PHONY: shortcut
shortcut: ## Setup macOS keyboard shortcuts
	./setup-mac-shortcuts.sh

~/bin:
	@test -L $@ || ln -sf $(PWD) $@

bash-my-aws: ~/.bash-my-aws

~/.bash-my-aws:
	git clone https://github.com/bash-my-aws/bash-my-aws.git ~/.bash-my-aws

~/bin/semver: | $(WGET) ~/bin ~/.zsh.site-functions
	wget --quiet https://github.com/mhristof/semver/releases/download/v0.7.0/semver_0.7.0_$(UNAME)_amd64 -O ~/bin/semver
	chmod +x ~/bin/semver
	~/bin/semver completion zsh > ~/.zsh.site-functions/_semver

.PHONY: gh
gh: ~/.local/bin/gh
~/.local/bin/gh: | ~/.local/bin
	wget --quiet https://github.com/cli/cli/releases/download/v2.2.0/gh_2.2.0_$(GH_OS)_amd64.tar.gz -O /tmp/gh.tar.gz
	tar xf /tmp/gh.tar.gz -C /tmp/
	mv /tmp/gh_*/bin/gh $@

.PHONY: golangci-lint
golangci-lint: ~/.local/bin/golangci-lint
~/.local/bin/golangci-lint: | ~/.local/bin
	curl --location --silent https://github.com/golangci/golangci-lint/releases/download/v1.44.0/golangci-lint-1.44.0-$(UNAME)-amd64.tar.gz > /tmp/golangci-lint.tar.gz
	tar xvf /tmp/golangci-lint.tar.gz -C /tmp/
	mv /tmp/golangci-lint-*-$(UNAME)-amd64/golangci-lint $@

.PHONY: gitbrowse
gitbrowse:  ~/bin/gitbrowse

~/bin/gitbrowse:
	@test -x $@ || curl --location --silent https://github.com/mhristof/gitbrowse/releases/download/v0.4.0/gitbrowse.$(UNAME) > $@
	@test -x $@ || chmod +x $@

.PHONY: yamllint
yamllint: $(YAMLLINT)

# Brew install targets from Makefile.Darwin
$(SPONGE):
	$(BREW) install moreutils
	$(BREW) link --overwrite parallel

%/coreutils:
	$(BREW) install coreutils

%/findutils:
	$(BREW) install findutils

$(GREP):
	$(BREW) install grep

$(CTAGS):
	@brew list universal-ctags &>/dev/null || $(BREW) install universal-ctags

$(PYLINT):
	pip3 install pylint

$(BANDIT):
	pip3 install bandit

$(BREW_BIN)/%:
	@brew list $* &>/dev/null || $(BREW) install $*

~/.zsh.site-functions:
	@test -d $@ || mkdir -p $@

~/.local/bin:
	@test -d $@ || mkdir -p $@

~/.%:
	@test -L $@ || ln -sf $(PWD)/$(shell basename $@) $@

# vim:ft=make
