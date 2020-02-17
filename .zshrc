# If you come from bash you might have to change your $PATH.

# Path to your oh-my-zsh installation.
source ~/.zshrc_local
export ZSH=~/.oh-my-zsh
export EDITOR=vim

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
plugins=(git docker aws)

source $ZSH/oh-my-zsh.sh

source ~/.dotfilesrc

eval $(thefuck --alias --enable-experimental-instant-mode)
[[ -r "/Users/Mike.Christofilopoulos/brew/etc/profile.d/bash_completion.sh" ]] && . "/Users/Mike.Christofilopoulos/brew/etc/profile.d/bash_completion.sh"
alias k=kubectl

[[ -f ~/.ca-bundle.crt ]] || {
    security find-certificate -a -p /Library/Keychains/System.keychain > ~/.ca-bundle.crt
    security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain >> ~/.ca-bundle.crt
}

export REQUESTS_CA_BUNDLE=~/.ca-bundle.crt
export NODE_EXTRA_CA_CERTS=~/.ca-bundle.crt
export AWS_SDK_LOAD_CONFIG=1
