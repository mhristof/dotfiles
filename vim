#!/usr/bin/env bash

command -v nvim &>/dev/null || brew install nvim
# shellcheck source=.lib
source ~/dotfiles/.lib

link ~/dotfiles/.vimrc ~/.vimrc
link ~/dotfiles/.config/nvim ~/.config/nvim

if [[ ! -d ~/.config/nvim/bundle/Vundle.vim ]]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.config/nvim/bundle/Vundle.vim
    vim +PluginInstall +qall
fi

nvim "$@"
