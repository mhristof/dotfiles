# If you come from bash you might have to change your $PATH.

# Path to your oh-my-zsh installation.
test -e "${HOME}/.zshrc_local" && source ~/.zshrc_local
export ZSH=~/.oh-my-zsh
export EDITOR=vim

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
plugins=(git docker aws)

source $ZSH/oh-my-zsh.sh

source ~/.dotfilesrc

source /Users/Mike.Christofilopoulos/Library/Preferences/org.dystroy.broot/launcher/bash/br
