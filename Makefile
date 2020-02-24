#
#

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:


default: brew vim essentials

essentials: ~/.brew/bin/htop ~/.brew/bin/watch less

dev: ~/.brew/bin/go vim

vim: ~/.vim

less: ~/.brew/bin/src-hilite-lesspipe.sh

git: ~/.gitignore_global ~/.gitconfig

dots: ~/.gitignore_global ~/.gitconfig  ~/.vimrc ~/.zshrc ~/.dotfilesrc  ~/.irbrc ~/.pythonrc.py ~/.config/thefuck/rules ~/.tmux.conf

~/.gitignore_global:
	ln -sf $(PWD)/.gitignore_global ~/.gitignore_global

~/.gitconfig:
	ln -sf $(PWD)/.gitconfig ~/.gitconfig

~/.brew/bin/src-hilite-lesspipe.sh:
	brew install source-highlight

~/.vim: ~/.vimrc ~/.brew/bin/shellcheck ~/.brew/bin/pycodestyle ~/.brew/bin/ag ~/.brew/bin/shellcheck ~/.brew/bin/pycodestyle
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall

~/.vimrc:
	ln -sf $(PWD)/.vimrc ~/.vimrc

~/.zshrc:
	ln -sf $(PWD)/.zshrc ~/.zshrc

~/.dotfilesrc:
	ln -sf $(PWD)/.dotfilesrc ~/.dotfilesrc

~/.oh-my-zsh:
	git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

zsh: ~/.zshrc ~/.dotfilesrc ~/.oh-my-zsh

brew: ~/.brew

fzf: ~/.brew/bin/fzf ~/.fzf.zsh

~/.fzf.zsh:
	$(shell brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

~/.brew/bin/autojump:
	brew install autojump

~/.irbrc:
	ln -sf $(PWD)/.irbrc ~/.irbrc

~/.pythonrc.py:
	ln -sf $(PWD)/.pythonrc.py ~/.pythonrc.py

python3: ~/.brew/bin/python3 ~/.irbrc ~/.pythonrc.py

~/.brew/opt/findutils/libexec/gnubin/xargs:
	brew install findutils

~/.brew/opt/coreutils:
	brew install coreutils

fuck: ~/.brew/bin/thefuck ~/.config/thefuck/rules ~/.brew/Cellar/thefuck/3.29_1/libexec/lib/python3.8/site-packages/kubernetes

~/.brew/Cellar/thefuck/3.29_1/libexec/lib/python3.8/site-packages/kubernetes:
	~/.brew/Cellar/thefuck/$(shell brew info --json thefuck | jq '.[0].installed[0].version')/libexec/bin/pip3 install kubernetes

~/.config/thefuck/rules:
	mkdir -p ~/.config/thefuck
	ln -sf $(PWD)/.config/thefuck/rules ~/.config/thefuck/rules

aws-azure-login: ~/.brew/bin/node
	npm install -g aws-azure-login

iterm: ~/.iterm2_shell_integration.zsh /Applications/iTerm.app

~/.iterm2_shell_integration.zsh:
	curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
	patch -p1 -R < data/iterm-zsh.patch

/Applications/iTerm.app: ~/.brew/bin/python3
	brew cask install iterm2

dock: ~/.brew/opt/findutils/libexec/gnubin/xargs ~/.brew/bin/dockutil
	dockutil --list | sed 's/file:.*//g' | xargs --no-run-if-empty -n1 -d'\n' dockutil --remove

/Applications/Alfred 4.app:
	brew cask install alfred
	open /Applications/Alfred\ 4.app/Contents/MacOS/Alfred

~/.brew/opt/make/libexec/gnubin/make:
	brew install make

~/.tmux.conf:
	ln -sf $(PWD)/.tmux.conf ~/.tmux.conf

docker: /Applications/Docker.app/Contents/MacOS/Docker

/Applications/Docker.app/Contents/MacOS/Docker:
	brew cask install docker

pbpaste: /tmp/alfred-pbpaste.alfredworkflow
	open /tmp/alfred-pbpaste.alfredworkflow

alfred: ~/.brew/bin/wget /tmp/alfred-tf-snippets.alfredworkflow pbpaste
	open /tmp/alfred-tf-snippets.alfredworkflow

/tmp/alfred-pbpaste.alfredworkflow:
	wget https://github.com/mhristof/alfred-pbpaste/releases/download/0.2.3/alfred-pbpaste.alfredworkflow -O alfred-pbpaste.alfredworkflow

/tmp/alfred-tf-snippets.alfredworkflow: ~/.brew/bin/jq
	wget https://github.com/mhristof/alfred-tf-snippets/releases/download/0.7.0/alfred-tf-snippets.alfredworkflow -O /tmp/alfred-tf-snippets.alfredworkflow

slack:
	brew cask install slack

bin:
	ln -sf $(PWD) ~/bin

pterm:
	pip3 install -U pterm

~/.brew:
	git clone https://github.com/Homebrew/brew.git ~/.brew

~/.brew/bin/%:
	brew install $*

# vim:ft=make
#
