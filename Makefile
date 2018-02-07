#
#

default: up

test: test-linux

test-linux:
	docker run -it -v $$PWD:/work -w /work ubuntu ./dotfiles/install.sh

bash:
	docker run -it -v $$PWD:/work -w /work ubuntu bash

macos:
	BOXES=gobadiah/macos-sierra vagrant up

clean:
	-vagrant destroy -f

all:
	@echo "Makefile needs your attention"

# vim:ft=make
#
