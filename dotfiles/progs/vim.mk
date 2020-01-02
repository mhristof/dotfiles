#
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

vim: $(VIM_BIN) ~/.vim ~/.vimrc ~/.vim/bundle

~/.vim/bundle: $(GIT_BIN)
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall

~/.vimrc:
	@find ~/.vimrc -type l -xtype d || ln -s $(PWD)/dotfiles/files/vimrc ~/.vimrc

~/.vim:
	mkdir -p ~/.vim


# vim:ft=make
#
