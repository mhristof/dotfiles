#!/usr/bin/env bash

command -v nvim &>/dev/null || brew install nvim
# shellcheck source=.lib
source ~/dotfiles/.lib

link ~/dotfiles/.config/nvim ~/.vimrc
link ~/dotfiles/.config/nvim ~/.config/nvim

if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall

    mkdir -p ~/.vim/bundle/ale/ale_linters/groovy/
    curl -sLO https://raw.githubusercontent.com/mhristof/ale-jenkinsfile/master/ale_jenkinsfile.vim --output ~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim

    brew install terraform-ls
fi

if pgrep -x "nvim" >/dev/null; then
    echo "Neovim is already running. Please restart Neovim to load any new plugins."
    unset NVIM_LISTEN_ADDRESS
fi
nvim "$@"
