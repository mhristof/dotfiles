#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
  echo "$*" 1>&2
  exit 1
}

GROUP=$(pwd | sed 's/.*gitlab.com\///g' | awk -F/ '{print $1}')
if [[ -z $GROUP ]]; then
  die "Not a gitlab project"
fi

echo "group: $GROUP"

if [[ -f /tmp/projects.json ]] && [[ $(find /tmp/projects.json -mmin +10) ]]; then
  PROJECTS=$(cat /tmp/projects.json)
else
  PROJECTS=$(glab api --paginate /groups/$GROUP/projects?include_subgroups=true)
  echo $PROJECTS >/tmp/projects.json
fi

for project in $(jq -r '.[].path_with_namespace' <<<"$PROJECTS"); do
  URL_ENCODED_PROJECT=$(echo $project | sed 's/\//%2F/g')
  # get access tokens
  for token in $(glab api --paginate /projects/$URL_ENCODED_PROJECT/access_tokens | jq '.[]' -c); do
    name=$(jq -r '.name' <<<"$token")
    # 2024-05-15
    exp_date=$(date -d $(jq -r '.expires_at' <<<"$token") +%s)
    days_to_expire=$(((exp_date - $(date +%s)) / 86400))

    if [[ $days_to_expire -lt 30 ]]; then
      echo "project: $project token: $name expires in: $days_to_expire days"
    fi
  done

done

exit 0
