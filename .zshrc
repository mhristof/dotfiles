# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"
#zmodload zsh/zprof


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
#set -x

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
export EDITOR=vim

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
fpath=($fpath ~/.zsh.autoload ~/.zsh.site-functions)
plugins=( fzf-tab docker )

function src {
    test -f $1 && source $1
}


src $HOME/.zshrc_local || true
src $ZSH/oh-my-zsh.sh
src $HOME/.dotfilesrc

autoload -U +X bashcompinit && bashcompinit

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"
