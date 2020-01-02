#
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

fzf: ~/.fzf.bash
.PHONY: fzf

~/.fzf.bash: ~/.fzf
	~/.fzf/install --completion --key-bindings --no-update-rc

~/.fzf: $(GIT_BIN)
	git clone http://github.com/junegunn/fzf.git ~/.fzf

# vim:ft=make
#
