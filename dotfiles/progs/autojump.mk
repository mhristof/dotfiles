#
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:


autojump: ~/.autojump/installed/bin/autojump
.PHONY: autojump

~/.autojump/installed/bin/autojump: ~/.autojump
	cd ~/.autojump
	SHELL=/bin/bash python3 ./install.py --destdir ~/.autojump/installed/
	sed -i "s/\#\!\/usr\/bin\/env\ python/\#\!\/usr\/bin\/env\ python3/" ~/.autojump/bin/autojump

~/.autojump: $(GIT_BIN)
	git clone git://github.com/wting/autojump.git ~/.autojump

# vim:ft=make
#
