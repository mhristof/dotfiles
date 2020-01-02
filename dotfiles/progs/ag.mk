#
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:


ifeq ($(shell uname -s),Darwin)
TARGET = /usr/local/bin/ag
else
TARGET = apt-silversearcher-ag
.PHONHY: apt-silversearcher-ag
endif

ag: $(TARGET)


# vim:ft=make
#
