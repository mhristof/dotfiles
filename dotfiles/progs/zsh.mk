#
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

zsh: ~/.oh-my-zsh ~/.zshrc ~/.dotfilesrc

~/.oh-my-zsh: $(GIT_BIN)
	git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# vim:ft=make
#
