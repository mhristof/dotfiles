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
DEV := essentials dots vim bat git ~/bin/semver $(LS) $(WATCH) $(JQ) $(AUTOJUMP)
include Makefile.$(shell uname -s)

UNAME := $(shell uname | tr '[:upper:]' '[:lower:]')
ifeq ($(shell which sw_vers),)
VENDOR := linux
else
VENDOR := apple
endif

PWD ?= $(shell pwd)
FIRST_VIM_PLUGIN := ~/.vim/bundle/$(shell basename $(shell grep Plugin .vimrc | head -2 | tail -1 | cut -d"'" -f2) .git)

.PHONY: default
default: brew vim essentials

.PHONY: essentials
essentials: $(HTOP) $(WATCH) less $(GREP) $(SPONGE) viddy

.PHONY: dev
dev: $(DEV)

.PHONY: go
go: $(GO) ~/go/bin/gojson

.PHONY: aws
aws: bash-my-aws $(BREW_BIN)/aws $(BREW_BIN)/kubectx

.PHONY: k8s
k8s: $(K9S)

$(BREW_BIN)/aws:
	pip3 install aws --user

$(BREW_BIN)/diff:
	brew install diffutils

.PHONY: vim
vim: $(VIM) ~/.vim $(PYTHON3)

.PHONY: less
less: $(SRCHILITE)

.PHONY: git
git: ~/.gitignore.global ~/.gitconfig ~/.gitconfig.github gh

.PHONY: ln
ln: dots

.PHONY: dots
dots: ~/.gitignore_global ~/.gitconfig  ~/.vimrc ~/.zshrc ~/.dotfilesrc  ~/.irbrc ~/.pythonrc.py ~/.tmux.conf ~/.p10k.zsh ~/.config/nvim/init.vim

~/.config/nvim/init.vim:
	ln -sf $(PWD)/.config/nvim/init.vim $@

~/.fzf-tab:
	git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

~/.p10k.zsh:
	brew install romkatv/powerlevel10k/powerlevel10k
	ln -sf $(PWD)/$(shell basename $@) $@

$(BREW_BIN)/src-hilite-lesspipe.sh:
	$(BREW) install source-highlight

# ~/.vim is defined as PHONY as its created indirectly via the vundle clone.
# This is a 'fix' to prevent subsequent runs to use the catch-all 'ln -sf' command
# when typing 'make vim'
.PHONY: ~/.vim
~/.vim: ~/.vim/bundle/Vundle.vim ~/.vimrc vim-tools vim-linters $(FIRST_VIM_PLUGIN) ~/bin/gitbrowse

.PHONY: vim-linters
vim-linters: $(BANDIT) $(SHELLCHECK) $(PYCODESTYLE)  $(PYLINT)  tflint golangci-lint ~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim  ~/.vim/bundle/ale/ale_linters/terraform/checkov.vim $(YAMLLINT) shfmt


.PHONY: bandit
bandit: $(BANDIT)

.PHONY: vim-tools
vim-tools: $(AG) ctags $(VIM)

~/.vim/bundle/Vundle.vim:
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

$(FIRST_VIM_PLUGIN):
	echo $(FIRST_VIM_PLUGIN)
	vim +PluginInstall +qall

.PHONY: tflint
tflint: ~/.local/bin/tflint ~/.tflint.d/plugins/tflint-ruleset-aws
.PHONY: tflint-clean
tflint-clean: 
	rm ~/.local/bin/tflint ~/.tflint.d -r

~/.local/bin/tflint: ~/.local/bin /usr/bin/unzip
	curl --location --silent https://github.com/terraform-linters/tflint/releases/download/v0.33.1/tflint_$(UNAME)_amd64.zip > /tmp/tflint.zip
	unzip /tmp/tflint.zip
	mv tflint $@

~/.tflint.d/plugins/tflint-ruleset-aws: $(TFLINT) ~/.tflint.hcl /usr/bin/unzip
	curl --location --silent https://github.com/terraform-linters/tflint-ruleset-aws/releases/download/v0.9.0/tflint-ruleset-aws_$(UNAME)_amd64.zip > /tmp/tflint-ruleset-aws.zip
	unzip /tmp/tflint-ruleset-aws.zip
	mkdir -p $(shell dirname $@)
	mv tflint-ruleset-aws $@

.PHONY: checkov
checkov: ~/.local/bin/checkov

~/.local/bin/checkov:
	pip install --user checkov

~/bin/checkov2vim: $(CHECKOV) | ~/bin
	curl -sL https://github.com/mhristof/checkov2vim/releases/download/v0.2.0/checkov2vim_0.2.0_$(UNAME)_amd64 > $@
	chmod +x $@

~/.vim/bundle/ale/ale_linters/terraform/checkov.vim: ~/bin/checkov2vim | $(FIRST_VIM_PLUGIN)
	~/bin/checkov2vim generate --dest $@

~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim: | $(CURL) $(FIRST_VIM_PLUGIN)
	mkdir -p ~/.vim/bundle/ale/ale_linters/groovy/
	curl -sLO https://raw.githubusercontent.com/mhristof/ale-jenkinsfile/master/ale_jenkinsfile.vim --output ~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim

.PHONY: viddy
viddy: ~/.local/bin/viddy

~/.local/bin/viddy: $(BREW_BIN)/wget | ~/.local/bin /usr/bin/tar
	wget -O /tmp/viddy.tar.gz https://github.com/sachaos/viddy/releases/download/v0.3.3/viddy_0.3.3_$(shell uname)_x86_64.tar.gz
	tar xvf /tmp/viddy.tar.gz -C /tmp/
	mv /tmp/viddy ~/.local/bin/

.PHONY: ctags
ctags: $(CTAGS) ~/.ctags.d

$(BREW_BIN)/curl/bin/curl:
	$(BREW) install curl

~/.zshrc: ~/.zsh.autoload
	ln -sf $(PWD)/$(shell basename $@) $@

~/.oh-my-zsh:
	git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

.PHONY: zsh
zsh: $(ZSH) ~/.zshrc ~/.dotfilesrc ~/.oh-my-zsh ~/.fzf-tab


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

aws-azure-login: $(BREW_BIN)/node
	npm install -g aws-azure-login@1.13.0

.PHONY: iterm
iterm: /Applications/iTerm.app germ

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

dock: $(XARGS) $(BREW_BIN)/dockutil
	dockutil --list | sed 's/file:.*//g' | xargs --no-run-if-empty -n1 dockutil --remove
	dockutil --remove 'App Store'
	dockutil --remove 'System Preferences'

/Applications/Alfred 4.app:
	brew install alfred
	open /Applications/Alfred\ 4.app/Contents/MacOS/Alfred

$(BREW_BIN)/make/libexec/gnubin/make:
	$(BREW) install make

.PHONY: docker
docker: /Applications/Docker.app/Contents/MacOS/Docker

/Applications/Docker.app/Contents/MacOS/Docker:
	brew cask install docker

pbpaste: /tmp/alfred-pbpaste.alfredworkflow
	open /tmp/alfred-pbpaste.alfredworkflow

alfred: $(BREW_BIN)/wget pbpaste $(GREP) /tmp/alfred-qrencode.alfredworkflow
	open /tmp/alfred-tf-snippets.alfredworkflow


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

/tmp/alfred-tf-snippets.alfredworkflow: $(BREW_BIN)/jq
	wget https://github.com/mhristof/alfred-tf-snippets/releases/download/0.7.0/alfred-tf-snippets.alfredworkflow -O /tmp/alfred-tf-snippets.alfredworkflow

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

.PHONY: exa
exa: $(EXA)

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
shortcut:
	./setup-mac-shortcuts.sh

~/bin:
	ln -sf $(PWD) ~/bin

bash-my-aws: ~/.bash-my-aws

~/.bash-my-aws:
	git clone https://github.com/bash-my-aws/bash-my-aws.git ~/.bash-my-aws

~/.brew:
	git clone https://github.com/Homebrew/brew.git ~/.brew
	$(BREW) tap homebrew/core
	$(BREW) --version

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
	curl --location --silent https://github.com/mhristof/gitbrowse/releases/download/v0.4.0/gitbrowse.$(UNAME) > $@
	chmod +x $@

.PHONY: yamllint
yamllint: $(YAMLLINT)

~/.zsh.site-functions:
	mkdir -p $@

~/.local/bin:
	mkdir -p $@

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


