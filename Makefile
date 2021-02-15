#
#

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:


include Makefile.$(shell uname -s)

default: brew vim essentials

essentials: $(HTOP) $(WATCH) less $(GREP) $(SPONGE)

dev: vim git semver

go: $(GO) ~/go/bin/gojson 

aws: bash-my-aws ~/.brew/bin/aws ~/brew/bin/kubectx

~/.brew/bin/aws:
	pip3 install aws --user

vim: $(VIM) ~/.vim $(PYTHON3)

less: $(SRCHILITE)

git: ~/.gitignore_global ~/.gitconfig ~/.gitconfig_github

ln: dots

dots: ~/.gitignore_global ~/.gitconfig  ~/.vimrc ~/.zshrc ~/.dotfilesrc  ~/.irbrc ~/.pythonrc.py ~/.tmux.conf

~/.%:
	ln -sf $(PWD)/$(shell basename $@) $@

~/.brew/bin/src-hilite-lesspipe.sh:
	$(BREW) install source-highlight

~/.vim: ~/.vimrc $(SHELLCHECK) $(PYCODESTYLE) $(AG) ~/.ctags.d $(PYLINT) $(VIM)
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall
	# this requires plugins to be installed since it creates a subfolder in there
	make ~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim
	make ~/.vim/bundle/ale/ale_linters/terraform/checkov.vim

~/bin/checkov2vim: ~/bin
	curl -sL https://github.com/mhristof/checkov2vim/releases/latest/download/checkov2vim.$(shell uname | tr '[:upper:]' '[:lower:]') > $@
	chmod +x $@

~/.vim/bundle/ale/ale_linters/terraform/checkov.vim: ~/bin/checkov2vim
	mkdir -p $(shell dirname $@)
	~/bin/checkov2vim generate --dest $@

~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim: $(CURL)
	mkdir -p ~/.vim/bundle/ale/ale_linters/groovy/
	cd ~/.vim/bundle/ale/ale_linters/groovy/
	curl -sLO https://raw.githubusercontent.com/mhristof/ale-jenkinsfile/master/ale_jenkinsfile.vim

~/.brew/opt/curl/bin/curl:
	$(BREW) install curl


~/.zshrc: ~/.zsh.autoload
	ln -sf $(PWD)/$(shell basename $@) $@

~/.oh-my-zsh:
	git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

zsh: $(ZSH) ~/.zshrc ~/.dotfilesrc ~/.oh-my-zsh

brew: ~/.brew

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

iterm: ~/.iterm2_shell_integration.zsh /Applications/iTerm.app ~/bin/germ

~/.iterm2_shell_integration.zsh: ~/.brew/opt/curl/bin/curl
	curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
	patch -p1 -R < data/iterm-zsh.patch

/Applications/iTerm.app: ~/.brew/bin/python3
	brew cask install iterm2

~/bin/germ:
	wget https://github.com/mhristof/germ/releases/download/v1.8.3/germ.darwin -O ~/bin/germ
	chmod +x ~/bin/germ
	~/bin/germ autocomplete > ~/.brew/share/zsh/site-functions/_germ

dock: ~/.brew/opt/findutils/libexec/gnubin/xargs ~/.brew/bin/dockutil
	dockutil --list | sed 's/file:.*//g' | xargs --no-run-if-empty -n1 -d'\n' dockutil --remove

/Applications/Alfred 4.app:
	brew cask install alfred
	open /Applications/Alfred\ 4.app/Contents/MacOS/Alfred

~/.brew/opt/make/libexec/gnubin/make:
	$(BREW) install make

docker: /Applications/Docker.app/Contents/MacOS/Docker

/Applications/Docker.app/Contents/MacOS/Docker:
	brew cask install docker

pbpaste: /tmp/alfred-pbpaste.alfredworkflow
	open /tmp/alfred-pbpaste.alfredworkflow

alfred: ~/.brew/bin/wget /tmp/alfred-tf-snippets.alfredworkflow pbpaste $(GREP)
	open /tmp/alfred-tf-snippets.alfredworkflow

/tmp/alfred-pbpaste.alfredworkflow:
	wget https://github.com/mhristof/alfred-pbpaste/releases/download/0.6.3/alfred-pbpaste.alfredworkflow -O alfred-pbpaste.alfredworkflow

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


~/bin/semver:
	wget https://github.com/mhristof/semver/releases/download/v0.5.0/semver.darwin -O ~/bin/semver
	chmod +x ~/bin/semver
	~/bin/semver autocomplete > ~/.brew/share/zsh/site-functions/_semver

~/.brew/bin/%:
	$(BREW) install $*

.PHONY: build
build: .build

.build: dockerfiles/linux
	docker build -f dockerfiles/linux -t dotfiles .
	touch .build

linux-test:
	docker run dotfiles make vim

hub: build
	docker build -f dockerfiles/hub -t mhristof/dotfiles .

push:
	docker push mhristof/dotfiles

run: .build
	docker run -it dotfiles bash

# vim:ft=make
#


