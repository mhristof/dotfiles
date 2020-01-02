#
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

vault: /usr/bin/unzip
	wget --quiet -O /tmp/vault.zip https://releases.hashicorp.com/vault/1.3.0/vault_1.3.0_$(shell uname | tr A-Z a-z)_amd64.zip
	unzip -o /tmp/vault.zip -d ~/bin/
.PHONY: vault

# vim:ft=make
#
