#!/usr/bin/env bash

set -euo pipefail

CACHE=$HOME/.cache/alfred/$(basename "$0")/
mkdir -p "$CACHE"

VALID_LABELS=$CACHE/valid-labels.log

if [[ ! -f $VALID_LABELS ]]; then
  for hostname in $(logcli labels hostname 2>/dev/null); do
    while read -r line; do
      set +e
      container_name=$(grep -oP 'container_name="[^"]+"' <<<"$line" | cut -d'"' -f2)
      docker_compose_service=$(grep -oP 'docker_compose_service="[^"]+"' <<<"$line" | cut -d'"' -f2)
      service_name=$(grep -oP 'service_name="[^"]+"' <<<"$line" | cut -d'"' -f2)
      set -e

      if [[ -n $container_name ]]; then
        echo "hostname: $hostname, container_name: $container_name" >>"$VALID_LABELS"
      fi

      if [[ -n $docker_compose_service ]]; then
        echo "hostname: $hostname, docker_compose_service: $docker_compose_service" >>"$VALID_LABELS"
      fi

      if [[ -n $service_name ]]; then
        echo "hostname: $hostname, service_name: $service_name" >>"$VALID_LABELS"
      fi

    done < <(logcli query '{hostname="'$hostname'"}' --limit=0 --since=1h --quiet)
  done

  sort -u "$VALID_LABELS" >"$VALID_LABELS.tmp"
  mv "$VALID_LABELS.tmp" "$VALID_LABELS"
fi

OUTPUT=$(mktemp -t output.XXXXXXXXXX)

echo "output file $OUTPUT" >&2

cat <<EOF >"$OUTPUT"
{"items": [
EOF

while read -r line; do
  #echo "$line"
  uid="$line"
  # hostname: marketmaker-ape1-az2-1, service_name: varlogs
  hostname=$(grep -oP 'hostname: \K[^,]+' <<<"$line")
  # remove hostname from the line
  title=$(sed -e "s/hostname: $hostname, //g" <<<"$line")

  cat <<EOF >>"$OUTPUT"
    {
        "uid": "$uid",
        "title": "$title",
        "subtitle": "$hostname",
        "arg": "$uid"
    },
EOF
done <"$VALID_LABELS"

# trim last comma
sed -i -e '$ s/,$//' "$OUTPUT"

cat <<EOF >>"$OUTPUT"
]}
EOF

jq . "$OUTPUT"
