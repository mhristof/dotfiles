# If you come from bash you might have to change your $PATH.
#set -x

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
export EDITOR=vim

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
plugins=(git docker)

function src {
    test -f $1 && source $1
}


src $HOME/.zshrc_local || true
src $ZSH/oh-my-zsh.sh
src $HOME/.dotfilesrc
src $HOME/Library/Preferences/org.dystroy.broot/launcher/bash/br || true
src "${fpath[1]}/_germ" && compdef _germ germ
