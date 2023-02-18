#!/usr/bin/env bash

command -v nvim &>/dev/null || brew install nvim
# shellcheck source=.lib
source ~/dotfiles/.lib

link ~/dotfiles/.vimrc ~/.vimrc
link ~/dotfiles/.config/nvim ~/.config/nvim

if [[ ! -d ~/.config/nvim/bundle/Vundle.vim ]]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.config/nvim/bundle/Vundle.vim
    vim +PluginInstall +qall

    mkdir -p ~/.vim/bundle/ale/ale_linters/groovy/
    curl -sLO https://raw.githubusercontent.com/mhristof/ale-jenkinsfile/master/ale_jenkinsfile.vim --output ~/.vim/bundle/ale/ale_linters/groovy/ale_jenkinsfile.vim

    brew install hashicorp/tap/terraform-ls node yarn
    (
        cd ~/.vim/bundle/coc.nvim
        yarn install
        yarn build
    )
fi

nvim "$@"
