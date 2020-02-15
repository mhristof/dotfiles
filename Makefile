#
#

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

help:  ## Show this help.
	@fgrep -h "##" Makefile* | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | column -t -s':' | sort -u


default: brew vim

vim: ~/.vimrc ~/.vim ~/.brew/bin/ag

less: ~/.brew/bin/src-hilite-lesspipe.sh

git: ~/.gitignore_global ~/.gitconfig


~/.gitignore_global:
	ln -sf $(PWD)/.gitignore_global ~/.gitignore_global

~/.gitconfig:
	ln -sf $(PWD)/.gitconfig ~/.gitconfig

~/.brew/bin/src-hilite-lesspipe.sh:
	brew install source-highlight

~/.brew/bin/ag:
	brew install ag

~/.vim:
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall

~/.vimrc:
	ln -sf $(PWD)/.vimrc ~/.vimrc

~/.zshrc:
	ln -sf $(PWD)/.zshrc ~/.zshrc

~/.dotfilesrc:
	ln -sf $(PWD)/.dotfilesrc ~/.dotfilesrc

~/.oh-my-zsh:
	git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

zsh: ~/.zshrc ~/.dotfilesrc ~/.oh-my-zsh

brew: ~/.brew

~/.brew/bin/fzf:
	brew install fzf

~/.brew/bin/autojump:
	brew install autojump

~/.irbrc:
	ln -sf $(PWD)/.irbrc ~/.irbrc

~/.pythonrc.py:
	ln -sf $(PWD)/.pythonrc.py ~/.pythonrc.py

python3: ~/.brew/bin/python3

~/.brew/bin/python3: ~/.irbrc ~/.pythonrc.py
	brew install python3

~/.brew/opt/findutils/libexec/gnubin/xargs:
	brew install findutils

/Applications/iTerm.app: ~/.brew/bin/python3
	brew cask install iterm2

~/.brew/bin/dockutil:
	brew install dockutil

dock: ~/.brew/opt/findutils/libexec/gnubin/xargs ~/.brew/bin/dockutil
	dockutil --list | sed 's/file:.*//g' | xargs -n1 -d'\n' dockutil --remove

/Applications/Alfred 4.app:
	brew cask install alfred
	open /Applications/Alfred\ 4.app/Contents/MacOS/Alfred

~/.brew/opt/make/libexec/gnubin/make:
	brew install make

~/.tmux.conf:
	ln -sf $(PWD)/.tmux.conf ~/.tmux.conf

docker: /Applications/Docker.app/Contents/MacOS/Docker

/Applications/Docker.app/Contents/MacOS/Docker:
	brew cask install docker

~/.brew/bin/wget:
	brew install wget

alfred: ~/.brew/bin/wget /tmp/alfred-tf-snippets.alfredworkflow /tmp/alfred-pbpaste.alfredworkflow
	open /tmp/alfred-tf-snippets.alfredworkflow
	open /tmp/alfred-pbpaste.alfredworkflow

/tmp/alfred-pbpaste.alfredworkflow:
	wget https://github.com/mhristof/alfred-pbpaste/releases/download/0.2.3/alfred-pbpaste.alfredworkflow -O alfred-pbpaste.alfredworkflow

~/.brew/bin/jq:
	brew install jq

/tmp/alfred-tf-snippets.alfredworkflow: ~/.brew/bin/jq
	wget https://github.com/mhristof/alfred-tf-snippets/releases/download/0.7.0/alfred-tf-snippets.alfredworkflow -O /tmp/alfred-tf-snippets.alfredworkflow

slack:
	brew cask install slack

bin:
	ln -sf $(PWD) ~/bin

~/.brew:
	git clone https://github.com/Homebrew/brew.git ~/.brew

# vim:ft=make
#
