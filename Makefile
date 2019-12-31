#
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

default: up

test: test-linux

test-linux:
	docker run -it -v $$PWD:/work -w /work ubuntu ./dotfiles/install.sh

bash:
	docker run -it -v $$PWD:/work -w /work ubuntu bash

macos:
	BOXES=gobadiah/macos-sierra vagrant up

brew /usr/local/bin/brew: /usr/local/Homebrew/bin/brew
.PHONY: brew

/usr/local/Homebrew/bin/brew:
	/usr/bin/ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

vim: brew /usr/local/bin/vim ~/.vim ~/.vimrm ~/.vim/bundle

~/.vim/bundle:
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall

~/.vimrm:
	@find /Users/mhristof/.vimrc -type l -xtype d || ln -s $(PWD)/dotfiles/files/vimrc ~/.vimrc

~/.vim:
	mkdir -p ~/.vim

/usr/local/bin/vim:
	brew install vim

clean:
	-vagrant destroy -f

all:
	@echo "Makefile needs your attention"

# vim:ft=make
#
