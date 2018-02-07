#
#

default: up

up:
	BOXES=ubuntu/xenial64 vagrant up


clean:
	vagrant destroy -force

all:
	@echo "Makefile needs your attention"


# vim:ft=make
#
