#
#

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

terraform: /usr/bin/unzip
	wget --quiet -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_$(shell uname | tr A-Z a-z)_amd64.zip
	unzip -o /tmp/terraform.zip -d ~/bin/

# vim:ft=make
#
