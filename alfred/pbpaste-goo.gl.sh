#! /usr/bin/env bash
# image: https://fthmb.tqn.com/jVbVy2S4MDKW77QW-j3ya7u98XQ=/768x0/filters:no_upscale()/goo_gl-56a4010c3df78cf7728052e9.jpg
# :vi ft=bash:
#
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

LOG=/tmp/$(basename $0).log

echo "$(date --iso=seconds) converting to goo.gl" >> $LOG
pbpaste >> $LOG
echo '' >> $LOG

curl --silent https://www.googleapis.com/urlshortener/v1/url?key="$(security find-generic-password -a GOOGLE_URLSHORTENER_KEY -s google -w)" \
  -H 'Content-Type: application/json' \
  -d '{"longUrl": "'$(pbpaste)'"}' | jq -r '.id'

echo "$(date --iso=seconds) done. $(pbpaste)" >> $LOG

exit 0
