# If you come from bash you might have to change your $PATH.
#set -x

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
export EDITOR=vim

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
fpath=($fpath ~/.zsh.autoload ~/.zsh.site-functions)

function src {
    test -f $1 && source $1
}


src $HOME/.zshrc_local || true
src $ZSH/oh-my-zsh.sh
src $HOME/.dotfilesrc
src $HOME/Library/Preferences/org.dystroy.broot/launcher/bash/br || true
src "${fpath[1]}/_germ" && compdef _germ germ
src "${fpath[1]}/_semver" && compdef _semver semver

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /Users/mhristof/.brew/bin/terraform terraform
